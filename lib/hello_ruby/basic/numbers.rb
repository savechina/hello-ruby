# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 数字与数值运算
    module Numbers
      def self.run
        puts "=== 数字与数值运算 ==="
        puts

        # 1. 整数类型: Ruby 3 中 Fixnum 和 Bignum 已统一为 Integer,
        # 不再区分小整数和大整数, 内部自动管理大数
        small_int = 42
        big_int = 999_999_999_999_999_999
        huge_int = 2**100

        puts "1. 整数类型 (Integer)"
        puts "  小整数: #{small_int} (class: #{small_int.class})"
        puts "  大整数: #{big_int} (class: #{big_int.class})"
        puts "  超大整数: #{huge_int} (class: #{huge_int.class})"
        puts "  Ruby Integer 支持任意精度（自动处理大数，没有 MIN/MAX 限制）"
        puts

        # 2. 浮点数: IEEE 754 双精度, 有效精度约 15-17 位十进制数, 注意精度误差
        pi = 3.14159265358979
        tiny = 1.0e-10
        huge_float = 1.5e20

        puts "2. 浮点数 (Float)"
        puts "  pi = #{pi}"
        puts "  科学计数法: #{tiny} (class: #{tiny.class})"
        puts "  科学计数法: #{huge_float} (class: #{huge_float.class})"
        puts "  Float::DIG = #{Float::DIG} (有效精度位数)"
        puts "  Float::EPSILON = #{Float::EPSILON} (1.0 到下一个浮点的差)"
        puts
        puts "  浮点精度问题:"
        puts "    0.1 + 0.2 = #{0.1 + 0.2} (不是 0.3)"
        puts "    (0.1 + 0.2).round(10) == 0.3 -> #{(0.1 + 0.2).round(10) == 0.3}"
        puts

        # 3. BigDecimal: 金融级精确计算, 需要 stdlib
        require "bigdecimal"
        require "bigdecimal/util"

        puts "3. BigDecimal (精确计算)"
        exact = BigDecimal("0.1") + BigDecimal("0.2")
        puts "  BigDecimal('0.1') + BigDecimal('0.2') = #{exact}"
        price = BigDecimal("99.99")
        tax = BigDecimal("0.13")
        total = price * (1 + tax)
        puts "  ￥#{price} * 1.13 = ￥#{total.round(2)} (金额计算)"
        puts

        # 4. 算术运算符
        a = 17
        b = 5

        puts "4. 算术运算符 (a=#{a}, b=#{b})"
        puts "  #{a} + #{b} = #{a + b}"
        puts "  #{a} - #{b} = #{a - b}"
        puts "  #{a} * #{b} = #{a * b}"
        puts "  #{a} / #{b} = #{a / b} (整数除法)"
        puts "  #{a}.to_f / #{b} = #{a.to_f / b} (浮点除法)"
        puts "  #{a} % #{b} = #{a % b} (取模)"
        puts "  #{a} ** #{b} = #{a ** b} (幂运算)"
        puts "  #{a}.divmod(#{b}) = #{a.divmod(b)} ([] 和余数)"
        puts

        # 5. 整数方法 (进制转换, 奇偶判断, 位运算等)
        n = 0xFF
        puts "5. 整数方法 (n=#{n})"
        puts "  #{n}.to_s(16) = #{n.to_s(16)} (十六进制)"
        puts "  #{n}.to_s(2)  = #{n.to_s(2)}  (二进制)"
        puts "  #{n}.to_s(8)  = #{n.to_s(8)}  (八进制)"
        puts "  #{n}.bit_length = #{n.bit_length}     (二进制位数)"
        puts "  #{n}.even?    = #{n.even?}    (偶数)"
        puts "  #{n}.odd?     = #{n.odd?}     (奇数)"
        puts "  42.even? = #{42.even?}, 43.odd? = #{43.odd?}"
        puts

        # 6. 浮点数舍入与取整
        f = 3.7
        nf = -3.7
        puts "6. 浮点数舍入 (f=#{f}, nf=#{nf})"
        puts "  #{f}.ceil     = #{f.ceil}     (向上)"
        puts "  #{f}.floor    = #{f.floor}    (向下)"
        puts "  #{f}.round    = #{f.round}    (四舍五入)"
        puts "  #{f}.truncate = #{f.truncate} (向零)"
        puts
        puts "  #{nf}.ceil     = #{nf.ceil}     (负数向上)"
        puts "  #{nf}.floor    = #{nf.floor}    (负数向下)"
        puts "  #{nf}.truncate = #{nf.truncate} (负数向零)"
        puts "  5.modulo(3)    = #{5.modulo(3)}    (取模)"
        puts "  -5 % 3         = #{-5 % 3}         (负数取模)"
        puts "  (-5).remainder(3) = #{(-5).remainder(3)} (取余)"
        puts

        # 7. 数字格式化输出 (sprintf 和 % 运算符)
        puts "7. 数字格式化"
        v = 42.123456789
        puts "  sprintf('%.2f', #{v}) = #{sprintf("%.2f", v)}"
        puts "  sprintf('%05d', 42) = #{sprintf("%05d", 42)}"
        puts "  sprintf('%x', 255)  = #{sprintf("%x", 255)}"
        puts "  sprintf('%08b', 42) = #{sprintf("%08b", 42)}"
        puts "  sprintf('%e', 1234567) = #{sprintf("%e", 1234567)}"
        puts "  % 运算符: '%.3f' % 3.14159 -> #{'%.3f' % 3.14159}"
        puts "  % 运算符: '%010d' % 42 -> #{'%010d' % 42}"
        puts

        # 8. 有理数 (Rational) 精确表示分数
        puts "8. 有理数 (Rational)"
        r1 = Rational(1, 3)
        r2 = Rational(2, 5)
        puts "  Rational(1, 3) = #{r1}"
        puts "  Rational(2, 5) + Rational(1, 3) = #{r2 + r1}"
        puts "  #{r1} * 3 = #{r1 * 3} (精确等于 1)"
        puts "  Rational(0.5) = #{Rational(0.5)} (从浮点创建)"
        puts

        # 9. 数值范围与特殊值 (Inf, NaN)
        puts "9. 数值范围与特殊值"
        puts "  Float::MAX    = #{Float::MAX}"
        puts "  Float::MIN    = #{Float::MIN} (最小正浮点数)"
        puts "  Float::INFINITY = #{Float::INFINITY}"
        puts "  Float::NAN = #{Float::NAN}"
        puts "  1.0 / 0.0 = #{1.0 / 0.0} (Infinity)"
        puts "  0.0 / 0.0 = #{0.0 / 0.0} (NaN)"
        puts "  Float::NAN.nan? = #{Float::NAN.nan?}"
        puts "  Float::INFINITY.infinite? = #{Float::INFINITY.infinite?}"
        puts "  1.0.finite? = #{1.0.finite?}"
        puts

        # 10. 类型转换 (to_i, to_s, to_f, Integer(), Float())
        puts "10. 类型转换"
        float_val = 3.14
        int_val = 42
        str_val = "123"
        puts "  #{float_val}.to_i = #{float_val.to_i} (转整数)"
        puts "  #{int_val}.to_f   = #{int_val.to_f}   (转浮点)"
        puts "  #{str_val}.to_i   = #{str_val.to_i}   (字符串转整数)"
        puts "  Integer('0xff')   = #{Integer("0xff")} (解析十六进制)"
        puts "  Float('1e2')      = #{Float("1e2")}    (解析科学计数法)"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "numbers", "数字与数值运算", Hello::Basic::Numbers)
