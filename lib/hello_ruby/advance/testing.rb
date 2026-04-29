# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 测试模式 — RSpec
    # 涵盖 describe/context/it、let/let!、before/after、shared_examples、subject、mock
    module Testing
      def self.run
        puts "=== RSpec 测试模式 ==="
        puts

        # 这是一个教学演示——展示 RSpec 的语法结构和最佳实践
        # 实际运行需要 rspec gem

        # --- 1. describe / context / it ---
        puts "--- 结构：describe / context / it ---"
        example_code = <<~RUBY
          RSpec.describe User do
            context "when creating a new user" do
              it "requires a name" do
                user = User.new(name: nil)
                expect(user.valid?).to be false
              end

              it "generates a unique ID" do
                user = User.new(name: "Alice")
                expect(user.id).to be_a(Integer)
              end
            end
          end
        RUBY
        puts "  #{example_code.strip}"
        puts

        # --- 2. let / let! — 延迟 / 即时赋值 ---
        puts "--- let vs let! ---"
        example_code2 = <<~RUBY
          RSpec.describe "let" do
            # let  — 懒加载，首次调用时才执行，结果会被缓存
            let(:user) { User.create(name: "Alice") }

            # let! — 立即执行（在每个 example 的 setup 阶段）
            let!(:post) { Post.create(title: "Hello", user: user) }

            it "reuses user" do
              expect(user.id).to eq(user.id) # 同一对象
            end
          end
        RUBY
        puts "  #{example_code2.strip}"
        puts

        # --- 3. before / after hooks ---
        puts "--- Hooks：before / after ---"
        example_code3 = <<~RUBY
          RSpec.describe FileProcessor do
            before(:each) do
              @file = Tempfile.new("test")
            end

            after(:each) do
              @file.close
              @file.unlink
            end

            # before(:suite) — 整个测试套件运行一次
            # before(:all)   — 每个 describe/context 运行一次
          end
        RUBY
        puts "  #{example_code3.strip}"
        puts

        # --- 4. shared_examples / include_examples ---
        puts "--- Shared Examples（共享示例） ---"
        example_code4 = <<~RUBY
          RSpec.shared_examples "a sortable collection" do
            it "sorts in ascending order" do
              expect(collection.sort).to eq(collection.sort.reverse.reverse)
            end

            it "returns self when already sorted" do
              sorted = collection.sort
              expect(sorted.sort).to eq(sorted)
            end
          end

          RSpec.describe Array do
            include_examples "a sortable collection" do
              let(:collection) { [3, 1, 2] }
            end
          end

          RSpec.describe Set do
            include_examples "a sortable collection" do
              let(:collection) { Set[3, 1, 2] }
            end
          end
        RUBY
        puts "  #{example_code4.strip}"
        puts "  → 将相同的行为测试复用在不同类上"
        puts

        # --- 5. subject ---
        puts "--- subject（被测试对象） ---"
        example_code5 = <<~RUBY
          RSpec.describe Array do
            subject { [1, 2, 3] }

            it { is_expected.to have(3).items }
            # is_expected 等同于 expect(subject)
          end

          # named subject
          RSpec.describe User do
            subject(:admin) { User.new(name: "Admin", role: :admin) }

            it { is_expected.to be_admin }
          end
        RUBY
        puts "  #{example_code5.strip}"
        puts

        # --- 6. 常用匹配器 ---
        puts "--- 常用匹配器 ---"
        example_code6 = <<~RUBY
          expect(value).to eq(42)           # 值相等（==）
          expect(value).to eql(42)          # 值和类型都相等（eql?）
          expect(value).to be true          # 严格 true
          expect(value).to be_truthy        # truthy（非 nil/false）
          expect(value).to be_nil
          expect(value).to be_a(Integer)    # 类型检查（is_a?）
          expect(value).to include("foo")   # 包含
          expect { action }.to change(obj, :state).from(:pending).to(:done)
          expect { action }.to raise_error(StandardError)
          expect(collection).to match_array([1, 2, 3]) # 顺序无关
          expect(value).to be_within(0.1).of(3.14)     # 浮点误差
        RUBY
        puts "  #{example_code6.strip}"
        puts

        # --- 7. Mock 与 Stub ---
        puts "--- Mock & Stub ---"
        example_code7 = <<~RUBY
          # double（测试替身）
          email_svc = double("EmailService")
          allow(email_svc).to receive(:send).and_return(true)
          email_svc.send("hello@ruby.dev")  # 返回 true，不真正发邮件

          # instance_double（类型安全）
          user = instance_double(User, name: "Alice", email: "a@b.c")

          # spy（验证调用）
          api = spy("Api")
          api.fetch("/users")
          expect(api).to have_received(:fetch).with("/users")

          # stub_chain（链式 stub）
          allow(User).to receive_message_chain(:where, :active, :count).and_return(5)
        RUBY
        puts "  #{example_code7.strip}"
        puts
        puts "  最佳实践:"
        puts "  - 优先使用 instance_double（会验证方法存在于真实类）"
        puts "  - 用 spy 代替 double，更容易追踪调用"
        puts "  - 只 stub 外部依赖（网络、数据库、文件系统）"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "testing", "测试模式 RSpec", Hello::Advance::Testing)
