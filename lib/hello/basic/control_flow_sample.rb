# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 控制流 — 实际运行的代码示例
    module ControlFlowSample
      def self.run
        puts "=== 控制流 ==="
        puts

        # 1. if / elsif / else — 表达式返回值
        score = 85
        grade = if score >= 90
          "A"
        elsif score >= 80
          "B"
        elsif score >= 70
          "C"
        else
          "D"
        end
        puts "1. if/elsif/else → #{score}分 = #{grade}"
        puts

        # 2. 三元运算符
        status = score >= 60 ? "及格" : "不及格"
        puts "2. 三元运算符: #{status}"
        puts

        # 3. unless
        password = "short"
        unless password.length >= 8
          puts "3. unless: 密码太短（长度 #{password.length} < 8）"
        end
        puts

        # 4. case / when — 值匹配
        day = "Monday"
        activity = case day
                   when "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
                     "工作日"
                   when "Saturday", "Sunday"
                     "周末"
                   else
                     "未知"
                   end
        puts "4. case/when: #{day} → #{activity}"

        # 5. case / when — Range 匹配
        temperature = 35
        weather = case temperature
                  when 0..15  then "寒冷"
                  when 16..25 then "舒适"
                  when 26..35 then "炎热"
                  else "极端"
                  end
        puts "5. case + Range: #{temperature}°C → #{weather}"

        # 6. case / when — Regexp 匹配
        input = "user@example.com"
        kind = case input
               when /\A[\w.+-]+@[\w-]+\.[\w.]+\z/ then "邮箱地址"
               when /\A\d{3}-\d{4}\z/              then "电话号码"
               else "未知格式"
               end
        puts "6. case + Regexp: #{input} → #{kind}"
        puts

        # 7. while 循环
        sum = 0
        i = 1
        while i <= 5
          sum += i
          i += 1
        end
        puts "7. while: 1+2+3+4+5 = #{sum}"
        puts

        # 8. until — 等效于 while not
        countdown = [3, 2, 1]
        results = []
        until countdown.empty?
          results << countdown.pop.to_s
        end
        results << "🚀!"
        puts "8. until: #{results.join(", ")}"
        puts

        # 9. times / each 迭代器
        times_result = 3.times.map { |i| "iter-#{i}" }
        puts "9. times: #{times_result.inspect}"

        colors = %w[red green blue]
        each_result = colors.map.with_index { |c, i| "[#{i}]=#{c}" }
        puts "   each_with_index: #{each_result.inspect}"
        puts

        # 10. next / break
        odd_only = (1..5).select { |n| next if n.even?; true }
        puts "10. next (跳过偶数): #{odd_only.inspect}"

        stopped = []
        (1..10).each { |n| break if n > 4; stopped << n }
        puts "   break (到4停止): #{stopped.inspect}"
        puts

        # 11. 短路运算符
        process = ->(val) { val && val.upcase || "N/A" }
        puts "11. 短路运算符:"
        puts "   process('hello'): #{process.call("hello")}"
        puts "   process(nil): #{process.call(nil).inspect}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "control_flow", "控制流", Hello::Basic::ControlFlowSample)
