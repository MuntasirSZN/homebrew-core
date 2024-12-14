class Moarvm < Formula
  desc "VM with adaptive optimization and JIT compilation, built for Rakudo"
  homepage "https://moarvm.org"
  url "https://github.com/MoarVM/MoarVM/releases/download/2024.12/MoarVM-2024.12.tar.gz"
  sha256 "7f8ae605a19189ebb48a51bae486bacd32141326df8289509825bdb1bee3984c"
  license "Artistic-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 arm64_sequoia: "cc350b8017771fd519ed075e4bf082378865be6bfcc17cf8a75220d7ee01c2cb"
    sha256 arm64_sonoma:  "7a5dc98c674af42fa378e985b5e7eb28685f3e0462aa55974863a07e4467d39a"
    sha256 arm64_ventura: "e0be9123ffd4e854a66e7b53715f12bf8b52a22235c91991c2b87c3277a12997"
    sha256 sonoma:        "963779bbab8068da8c1270962ba705791e382df6cfc96b7d1f81c4338fcdddc9"
    sha256 ventura:       "525b5f32f60932437b95c9baa1b96192eb2384719ac8a6578fac28533f80dd9d"
    sha256 x86_64_linux:  "7f1969a3430c43b3054da1962359607cadb30064ed2721cc39b1a03d29bf61ad"
  end

  depends_on "pkgconf" => :build
  depends_on "libtommath"
  depends_on "libuv"
  depends_on "zstd"

  uses_from_macos "perl" => :build
  uses_from_macos "libffi"

  conflicts_with "moar", because: "both install `moar` binaries"
  conflicts_with "rakudo-star", because: "rakudo-star currently ships with moarvm included"

  resource "nqp" do
    url "https://github.com/Raku/nqp/releases/download/2024.12/nqp-2024.12.tar.gz"
    sha256 "026ff25d7eaae299b2d644e46b389642774cdf51fd803047f4291731dc4b2477"
  end

  def install
    configure_args = %W[
      --c11-atomics
      --has-libffi
      --has-libtommath
      --has-libuv
      --optimize
      --pkgconfig=#{Formula["pkgconf"].opt_bin}/pkgconf
      --prefix=#{prefix}
    ]
    system "perl", "Configure.pl", *configure_args
    system "make", "realclean"
    system "make"
    system "make", "install"
  end

  test do
    testpath.install resource("nqp")
    out = Dir.chdir("src/vm/moar/stage0") do
      shell_output("#{bin}/moar nqp.moarvm -e 'for (0,1,2,3,4,5,6,7,8,9) { print($_) }'")
    end
    assert_equal "0123456789", out
  end
end
