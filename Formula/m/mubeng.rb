class Mubeng < Formula
  desc "Incredibly fast proxy checker & IP rotator with ease"
  homepage "https://github.com/mubeng/mubeng"
  url "https://github.com/mubeng/mubeng/archive/refs/tags/v0.21.0.tar.gz"
  sha256 "97e439a5bbc71e68b804dfdd5492161f436b32052979cc8dc8b44b71746d046b"
  license "Apache-2.0"
  head "https://github.com/mubeng/mubeng.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "42911f6ded89ba4b16d0fe35e69873445f56b7c4c94826c2d31acf40c81ede19"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "42911f6ded89ba4b16d0fe35e69873445f56b7c4c94826c2d31acf40c81ede19"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "42911f6ded89ba4b16d0fe35e69873445f56b7c4c94826c2d31acf40c81ede19"
    sha256 cellar: :any_skip_relocation, sonoma:        "b296c4c4a3229dbb319b40998a4b0e4c187160e64942df9ba9156adb128e5e73"
    sha256 cellar: :any_skip_relocation, ventura:       "b296c4c4a3229dbb319b40998a4b0e4c187160e64942df9ba9156adb128e5e73"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3963fd52069c9050fa652de6090f4b5ebbe5014e8c446a1293b71c3b0d70f5c5"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/mubeng/mubeng/common.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    expected = OS.mac? ? "no proxy file provided" : "has no valid proxy URLs"
    assert_match expected, shell_output("#{bin}/mubeng 2>&1", 1)

    assert_match version.to_s, shell_output("#{bin}/mubeng --version", 1)
  end
end
