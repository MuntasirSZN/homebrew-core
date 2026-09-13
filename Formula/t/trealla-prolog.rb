class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.74.tar.gz"
  sha256 "8932743c3752f5ca2fcd37fde05977f631d1be1ab4a1ae0ca6585bd0cec0efe0"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "6c15cf88705408fd1c0115d7f1c68c38c87d00ab2d3461d4fbbdb35e3fc3f2c1"
    sha256 arm64_tahoe:       "8ed332f561275ea682eed36afea73954c670ed578972fcdec611d43dd3212b66"
    sha256 arm64_sequoia:     "549feabdf200ffb70916fdc33cd9e6ac98cc66ebd46f0ab94705bc4c3663da54"
    sha256 arm64_linux:       "acdf405f2784614b1ab5b81f5a3879026e3622431ab2b76471eb87b996483a19"
    sha256 x86_64_linux:      "b119b3e291fef5091a8e701b28ea7f8cd4cb78e1b0735f73bb3293b0449b78c2"
  end

  depends_on "openssl@4"

  uses_from_macos "libedit"
  uses_from_macos "libffi"

  def install
    args = ["PREFIX=#{prefix}", "OPENSSL=openssl@4"]
    # macOS keeps ffi.h in an ffi/ subdirectory, which the build's plain
    # `#include <ffi.h>` misses. TARGET_CFLAGS is the makefile's append hook.
    args << "TARGET_CFLAGS=-I#{MacOS.sdk_path}/usr/include/ffi" if OS.mac?
    system "make", "install", *args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tpl --version")

    assert_equal "42", shell_output("#{bin}/tpl -g 'X is 6*7, write(X), halt'").chomp

    # library(assoc) is not embedded in the binary, so this also proves the
    # installed library path was baked in correctly.
    goal = "use_module(library(assoc)), list_to_assoc([a-1, b-2], A), " \
           "get_assoc(b, A, V), write(V), halt"
    assert_equal "2", shell_output("#{bin}/tpl -g '#{goal}'").chomp
  end
end
