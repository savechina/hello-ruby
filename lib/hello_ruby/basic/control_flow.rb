# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 控制流
    # if/elsif/else、case/when、unless、循环、迭代器、控制关键字
    module ControlFlow
      def self.run
        puts "=== 控制流 ==="
        puts

        # if / elsif / else
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
        puts "if/elsif 表达式: #{score}分 → #{grade}"
        # if 有返回值 — Ruby 中一切皆表达式
        puts

        # 三元运算符
        status = score >= 60 ? "及格" : "不及格"
        puts "三元运算符: #{status}"
        puts

        # unless — 等效于 if not（仅适用于简单否定）
        password = "secret123"
        unless password.length >= 8
          puts "unless: 密码长度不足！"
        end
        # 单行形式
        puts "unless 单行: #{password.length < 8 && "密码不够长"}"
        puts

        # case / when
        day = "Monday"
        activity = case day
                   when "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
                     "工作日"
                   when "Saturday", "Sunday"
                     "周末"
                   else
                     "未知"
                   end
        puts "case/when: #{day} → #{activity}"

        # case 使用 Range 匹配
        temperature = 35
        weather = case temperature
                  when 0..15   then "寒冷"
                  when 16..25  then "舒适"
                  when 26..35  then "炎热"
                  else "极端"
                  end
        puts "case with Range: #{temperature}°C → #{weather}"

        # case 使用正则匹配
        input = "user@example.com"
        kind = case input
               when /\A[\w.]+@[\w.]+\z/ then "邮箱地址"
               when /\A\d{3}-\d{4}\z/  then "电话号码"
               else "未知格式"
               end
        puts "case with Regexp: #{input} → #{kind}"
        puts

        # while 循环
        sum = 0
        i = 1
        while i <= 5
          sum += i
          i += 1
        end
        puts "while: 1+2+3+4+5 = #{sum}"
        puts

        # until — 等效于 while not
        countdown = 3
        until countdown == 0
          print "#{countdown}... "
          countdown -= 1
        end
        puts "🚀!"
        puts

        # for 循环（Ruby 中较少使用，通常用 each）
        print "for (1..3): "
        for n in 1..3
          print "#{n} "
        end
        puts
        puts

        # each 迭代器（Ruby 主流遍历方式）
        colors = %w[red green blue]
        print "each: "
        colors.each { |c| print "#{c} " }
        puts
        print "each_with_index: "
        colors.each_with_index { |c, i| print "[#{i}]=#{c} " }
        puts
        puts

        # next / break / redo
        puts "next（跳过偶数）："
        (1..5).each do |n|
          next if n.even?
          print "#{n} "
        end
        puts
        puts

        puts "break（到 4 停止）："
        (1..10).each do |n|
          break if n > 4
          print "#{n} "
        end
        puts
        puts

        # retry（仅用于 rescue 块内）
        # 见 exceptions.rb 中的示例
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "control_flow", "控制流", Hello::Basic::ControlFlow)
