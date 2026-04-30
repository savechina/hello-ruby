# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 测试模式 — RSpec-like 断言框架的实际执行演示
    class TestingSample
      def self.run
        puts "=== RSpec 测试框架模式（模拟实现） ==="
        puts

        # --- 1. 断言框架 ---
        puts "--- 1. 断言框架 ---"
        assertions = AssertionSuite.new

        assertions.expect(42).to.eq(42)
        assertions.expect("hello").to.include?("ell")
        assertions.expect([1, 2, 3]).to.have_count(3)
        assertions.expect(true).to.be_truthy
        assertions.expect(nil).to.be_nil

        puts "  通过断言:"
        assertions.results.each do |result|
          next unless result.passed?
          puts "    ✓ #{result.description}"
        end

        puts "  失败断言示例 (expect(1).to.eq(2)):"
        begin
          assertions.expect(1).to.eq(2)
        rescue MinitestAssertion
          puts "    ✗ 1 should eq 2 (caught as expected)"
        end
        puts

        # --- 2. describe/context/it 执行 ---
        puts "--- 2. 描述/上下文/示例结构 ---"
        runner = TestRunner.new

        # Manual test suite construction (模拟 describe/context/it)
        user_suite = TestDescribe.new("User")

        ctx1 = TestContext.new("when creating")
        ctx1.examples << TestExample.new("generates a unique id") do
          id = IdGenerator.next_id
          expect_id = IdGenerator.next_id
          raise "ids should differ" if id == expect_id
        end
        ctx1.examples << TestExample.new("sets created_at timestamp") do
          user = MockUser.new(name: "Alice")
          raise "created_at should be set" if user.created_at.nil?
        end

        ctx2 = TestContext.new("when validating")
        ctx2.examples << TestExample.new("requires a name") do
          begin
            MockUser.new(name: nil)
            raise "should have failed"
          rescue ValidationError
            # expected
          end
        end
        ctx2.examples << TestExample.new("accepts valid name") do
          user = MockUser.new(name: "Bob")
          raise "user should be valid" if user.nil?
        end

        user_suite.instance_variable_set(:@contexts, [ctx1, ctx2])

        runner.run_suite(user_suite)
        runner.print_summary
        puts

        # --- 3. let/let! 延迟赋值 ---
        puts "--- 3. let (延迟赋值) 模式 ---"
        let_demo = LetTester.new
        user1 = let_demo.let_user
        user2 = let_demo.let_user
        puts "  let 缓存验证: user1.object_id == user2.object_id: #{user1.object_id == user2.object_id}"
        puts "  user: #{user1.inspect}"

        post_data = let_demo.let_post
        puts "  let! 即时赋值: #{post_data.inspect}"
        puts

        # --- 4. before/after Hooks ---
        puts "--- 4. 生命周期 Hooks ---"
        hook_suite = HookSuite.new

        hook_suite.run do
          puts "    [test] 在 setup 和 teardown 之间执行"
        end
        puts "    setup 执行了: #{hook_suite.setup_called} 次"
        puts "    teardown 执行了: #{hook_suite.teardown_called} 次"
        puts

        # --- 5. 匹配器 ---
        puts "--- 5. 匹配器链 ---"
        matcher_demo = MatcherTests.new
        matcher_demo.test_raise_error
        matcher_demo.test_change
        matcher_demo.test_all_matchers
        puts

        # --- 6. Mock & Stub ---
        puts "--- 6. Mock & Stub ---"
        mock_repo = MockRepository.new
        mock_repo.stub(:find, { id: 1, name: "Alice" })
        mock_repo.stub(:count, 42)

        svc = ServiceLayer.new(mock_repo)
        user = svc.find_user(1)
        total = svc.user_count

        puts "  MockRepository 调用:"
        puts "    find(1) = #{user.inspect}"
        puts "    count() = #{total.inspect}"
        puts "    实际调用次数: find=#{mock_repo.call_count(:find)}, count=#{mock_repo.call_count(:count)}"

        spy = MethodSpy.new
        spy.process("data1")
        spy.process("data2")
        spy.process("data3")
        puts "  Spy 验证:"
        puts "    process called #{spy.process_calls.length} 次: #{spy.process_calls.inspect}"
        puts "    最后一次参数: #{spy.process_calls.last.inspect}"
        puts

        puts "=== 测试框架演示完成 ==="
      end
    end

    # --- 测试基础 ---
    class MinitestAssertion < StandardError; end

    class AssertionResult
      attr_reader :description, :passed

      def initialize(description, passed)
        @description = description
        @passed = passed
      end

      def passed?
        @passed
      end
    end

    class AssertionSuite
      attr_reader :results

      def initialize
        @results = []
      end

      def expect(value)
        AssertionExpectation.new(value, self)
      end

      def record(result)
        @results << result
      end
    end

    class AssertionExpectation
      def initialize(value, suite)
        @value = value
        @suite = suite
      end

      def to
        ToMatcher.new(@value, @suite)
      end
    end

    class ToMatcher
      def initialize(value, suite)
        @value = value
        @suite = suite
      end

      def eq(expected)
        description = "#{@value.inspect} should eq #{expected.inspect}"
        if @value == expected
          @suite.record(AssertionResult.new(description, true))
        else
          @suite.record(AssertionResult.new(description, false))
          raise MinitestAssertion, description
        end
      end

      def include?(substring)
        description = "#{@value.inspect} should include #{substring.inspect}"
        result = @value.to_s.include?(substring.to_s)
        @suite.record(AssertionResult.new(description, result))
        raise MinitestAssertion, description unless result
      end

      def have_count(expected)
        description = "collection count should be #{expected} (got #{@value.length})"
        result = @value.length == expected
        @suite.record(AssertionResult.new(description, result))
        raise MinitestAssertion, description unless result
      end

      def be_truthy
        description = "#{@value.inspect} should be truthy"
        result = !!@value
        @suite.record(AssertionResult.new(description, result))
        raise MinitestAssertion, description unless result
      end

      def be_nil
        description = "#{@value.inspect} should be nil"
        result = @value.nil?
        @suite.record(AssertionResult.new(description, result))
        raise MinitestAssertion, description unless result
      end
    end

    # --- describe/context/it ---
    class TestDescribe
      attr_reader :name, :contexts

      def initialize(name)
        @name = name
        @contexts = []
      end
    end

    class TestContext
      attr_reader :name, :examples

      def initialize(name)
        @name = name
        @examples = []
      end
    end

    class TestExample
      attr_reader :name, :block

      def initialize(name, &block)
        @name = name
        @block = block
      end
    end

    def describe(name, &block)
      suite = TestDescribe.new(name)
      instance_eval(&block)
      suite
    rescue
      # top-level define not available, use class method
      TestDescribe.new(name).tap do |suite|
        # nested context handling via yield
      end
    end

    def context(name, &block)
      ctx = TestContext.new(name)
      instance_eval(&block)
      ctx
    rescue
      TestContext.new(name)
    end

    def it(name, &block)
      TestExample.new(name, &block)
    end

    class TestRunner
      attr_reader :passed, :failed, :total

      def initialize
        @passed = 0
        @failed = 0
        @total = 0
      end

      def run_suite(suite)
        suite.contexts.each do |context|
          context.examples.each do |example|
            run_example("#{suite.name}/#{context.name}", example)
          end
        end
      end

      def run_example(prefix, example)
        @total += 1
        print "    #{prefix}/#{example.name} ... "
        begin
          example.block.call
          puts "PASS"
          @passed += 1
        rescue StandardError => e
          puts "FAIL (#{e.class}: #{e.message})"
          @failed += 1
        end
      end

      def print_summary
        puts "    Summary: #{@passed}/#{@total} passed, #{@failed} failed"
      end
    end

    # --- let/let! ---
    class LetTester
      def initialize
        @let_user = nil
      end

      def let_user
        @let_user ||= MockUser.new(name: "LazyUser")
      end

      def let_post
        { id: 1, title: "Eager Post", author: "LetTester" }
      end
    end

    # --- before/after ---
    class HookSuite
      attr_reader :setup_called, :teardown_called

      def initialize
        @setup_called = 0
        @teardown_called = 0
      end

      def setup
        @setup_called += 1
      end

      def teardown
        @teardown_called += 1
      end

      def run(&block)
        setup
        yield
      ensure
        teardown
      end
    end

    # --- 匹配器 ---
    class MatcherTests
      def test_raise_error
        block = -> { raise "division by zero"; 1 / 0 }
        begin
          block.call
          failed = true
        rescue StandardError
          failed = false
        end
        puts "  raise_error 匹配: #{failed ? 'FAIL' : 'PASS (caught exception)'}"
      end

      def test_change
        counter = CounterObject.new
        before = counter.value
        counter.increment
        after = counter.value
        changed = after - before == 1
        puts "  change 匹配: #{changed ? 'PASS (value changed by 1)' : 'FAIL'}"
      end

      def test_all_matchers
        data = { a: 1, b: [2, 3, 4] }
        puts "  eq: #{ {a: 1} == {a: 1} ? 'PASS' : 'FAIL' }"
        puts "  include: #{'hello world'.include?('world') ? 'PASS' : 'FAIL' }"
        puts "  be_a: #{1.is_a?(Integer) ? 'PASS' : 'FAIL' }"
        puts "  satisfy: #{(1..10).cover?(5) ? 'PASS' : 'FAIL' }"
        puts "  match: #{'hello'.match?(/hell\w/) ? 'PASS' : 'FAIL' }"
      end
    end

    class CounterObject
      attr_reader :value

      def initialize
        @value = 0
      end

      def increment
        @value += 1
      end
    end

    # --- Mock & Stub ---
    class MockRepository
      def initialize
        @stubs = {}
        @call_counts = Hash.new(0)
      end

      def stub(method_name, return_value)
        @stubs[method_name] = return_value
      end

      def method_missing(method_name, *_args)
        @call_counts[method_name] += 1
        if @stubs.key?(method_name)
          @stubs[method_name]
        else
          raise "Unexpected call: #{method_name}"
        end
      end

      def respond_to_missing?(_method_name, _include_private = false)
        true
      end

      def call_count(method_name)
        @call_counts[method_name]
      end
    end

    class MethodSpy
      attr_reader :process_calls

      def initialize
        @process_calls = []
      end

      def process(data)
        @process_calls << data
        "processed: #{data}"
      end
    end

    class ServiceLayer
      def initialize(repo)
        @repo = repo
      end

      def find_user(id)
        @repo.find(id)
      end

      def user_count
        @repo.count
      end
    end

    # --- 模拟用户模型 ---
    class MockUser
      attr_reader :name, :created_at

      def initialize(name:)
        raise ValidationError, "name required" if name.nil?
        @name = name
        @created_at = Time.now
      end
    end

    class ValidationError < StandardError; end

    class IdGenerator
      @@counter = 0
      @@mutex = Mutex.new

      def self.next_id
        @@mutex.synchronize do
          @@counter += 1
          @@counter
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "testing", "测试模式 RSpec", Hello::Advance::TestingSample)
