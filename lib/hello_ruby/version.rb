# typed: true
# frozen_string_literal: true

module Hello
  # 语义化版本号 — 无 Sorbet 签名（版本文件不参与类型检查）
  MAJOR = 0
  MINOR = 1
  TINY  = 0
  PRE   = nil

  VERSION = [MAJOR, MINOR, TINY, PRE].compact.join(".")
end
