class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://danielmiessler.com/p/fabric-origin-story"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.214.tar.gz"
  sha256 "ff9e643882a013be3f05efebbe54ffe18e7c02dd4dd5781ff87e3c6bcfb7cb6b"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f16ab30a3ff91d6f6d99ad396e75bf788d5a9a6dfde8b490ebf4d187a561cb9f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f16ab30a3ff91d6f6d99ad396e75bf788d5a9a6dfde8b490ebf4d187a561cb9f"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "f16ab30a3ff91d6f6d99ad396e75bf788d5a9a6dfde8b490ebf4d187a561cb9f"
    sha256 cellar: :any_skip_relocation, sonoma:        "d2565c9305264c64cb49715834561f844f5360122112b0554d80378f93d73482"
    sha256 cellar: :any_skip_relocation, ventura:       "d2565c9305264c64cb49715834561f844f5360122112b0554d80378f93d73482"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "efff2c60bf0a3460e1e1b26d34de8d7ff046cfc32cda548710957a30294a0447"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fabric-ai --version")

    (testpath/".config/fabric/.env").write("t\n")
    output = shell_output("#{bin}/fabric-ai --dry-run < /dev/null 2>&1")
    assert_match "error loading .env file: unexpected character", output
  end
end
