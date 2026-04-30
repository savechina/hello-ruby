# typed: true
# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

module Hello
  module Basic
    # 数字与数值运算 — 实际运行的代码示例
    module NumbersSample
      def self.run
        puts "=== 数字与数值运算 ==="
        puts

        # 1. Integer — Ruby 3 统一为 Integer
        small = 42
        big = 999_999_999_999_999_999
        huge = 2**100
        puts "1. Integer:"
        puts "   small: #{small} (#{small.class})"
        puts "   big: #{big}"
        puts "   2**100: #{huge}"
        puts "   #{big.class}: arbitrary precision"
        puts

        # 2. Float — IEEE 754 双精度
        pi = 3.14159265358979
        tiny = 1.0e-10
        puts "2. Float:"
        puts "   pi: #{pi} (#{pi.class})"
        puts "   1.0e-10: #{tiny}"
        puts "   Float::DIG (precision): #{Float::DIG}"
        puts "   Float::EPSILON: #{Float::EPSILON}"
        puts
        puts "   0.1 + 0.2: #{0.1 + 0.2} (not 0.3)"
        puts "   (0.1 + 0.2).round(10) == 0.3: #{(0.1 + 0.2).round(10) == 0.3}"
        puts

        # 3. BigDecimal — 精确计算
        exact = BigDecimal("0.1") + BigDecimal("0.2")
        price = BigDecimal("99.99")
        tax = BigDecimal("0.13")
        total = price * (1 + tax)
        puts "3. BigDecimal:"
        puts "   BigDecimal('0.1') + BigDecimal('0.2'): #{exact}"
        puts "   ¥#{price} * 1.13 = ¥#{total.round(2)}"
        puts

        # 4. 算术运算
        a = 17
        b = 5
        puts "4. Arithmetic (a=#{a}, b=#{b}):"
        puts "   +: #{a + b}"
        puts "   -: #{a - b}"
        puts "   *: #{a * b}"
        puts "   / (int div): #{a / b}"
        puts "   / (float div): #{a.to_f / b}"
        puts "   %: #{a % b}"
        puts "   **: #{a ** b}"
        puts "   divmod: #{a.divmod(b)}"
        puts

        # 5. 整数方法
        n = 0xFF
        puts "5. Integer methods (n=#{n} [= 0xFF]):"
        puts "   to_s(16): #{n.to_s(16)}"
        puts "   to_s(2): #{n.to_s(2)}"
        puts "   bit_length: #{n.bit_length}"
        puts "   even?: #{n.even?}"
        puts "   odd?: #{n.odd?}"
        puts

        # 6. 浮点舍入
        f = 3.7
        nf = -3.7
        puts "6. Rounding (f=#{f}, nf=#{nf}):"
        puts "   ceil: #{f.ceil}"
        puts "   floor: #{f.floor}"
        puts "   round: #{f.round}"
        puts "   truncate: #{f.truncate}"
        puts "   -3.7.ceil: #{nf.ceil}"
        puts "   -3.7.floor: #{nf.floor}"
        puts

        # 7. 格式化
        v = 42.123456789
        puts "7. Formatting:"
        puts "   sprintf('%.2f', #{v}): #{sprintf("%.2f", v)}"
        puts "   sprintf('%05d', 42): #{sprintf("%05d", 42)}"
        puts "   sprintf('%x', 255): #{sprintf("%x", 255)}"
        puts "   %.3f %% 3.14159: #{'%.3f' % 3.14159}"
        puts

        # 8. Rational
        r1 = Rational(1, 3)
        r2 = Rational(2, 5)
        puts "8. Rational:"
        puts "   Rational(1,3): #{r1}"
        puts "   Rational(2,5) + Rational(1,3): #{r2 + r1}"
        puts "   Rational(1,3) * 3: #{r1 * 3}"
        puts "   Rational(0.5): #{Rational(0.5)}"
        puts

        # 9. 特殊值
        puts "9. Special values:"
        puts "   Float::MAX: #{Float::MAX}"
        puts "   Float::INFINITY: #{Float::INFINITY}"
        puts "   1.0 / 0.0: #{1.0 / 0.0}"
        puts "   0.0 / 0.0: #{0.0 / 0.0}"
        puts "   Float::NAN.nan?: #{Float::NAN.nan?}"
        puts "   Float::INFINITY.infinite?: #{Float::INFINITY.infinite?}"
        puts

        # 10. 类型转换
        puts "10.类型转换:"
        puts "   3.14.to_i: #{3.14.to_i}"
        puts "   42.to_f: #{42.to_f}"
        puts "   '123'.to_i: #{"123".to_i}"
        puts "   Integer('0xff'): #{Integer("0xff")}"
        puts "   Float('1e2'): #{Float("1e2")}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "numbers_sample", "数字与数值运算", Hello::Basic::NumbersSample)
