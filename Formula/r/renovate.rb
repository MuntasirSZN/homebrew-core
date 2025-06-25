class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-41.9.0.tgz"
  sha256 "6e3d6680bf9443d6f5f9f1b32d3ffaa8a0d8e88765c19b666185f667eea37b3f"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "51a28fcaaa162deb5a29964ea847c984b231cb8ae155cf245c7188f4defad163"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "47fb2abc04c7a972aa8272315de5bbacbd2bf709b94a5bf86f3fff39b183354d"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "bf202ec2883c6cb72b5543b9a369827bd5dc1bf781b916c9d426b0cd70026562"
    sha256 cellar: :any_skip_relocation, sonoma:        "058ef5bff7a68fc4619d90a350b8ae39c34554239eeb85c68b88e0dc180d5592"
    sha256 cellar: :any_skip_relocation, ventura:       "8abcb1ee4d7610d1b5ad11b90e291b945267d95a8da9e55139dc2e31b9a31887"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "5908285996ca610b0cf3e5467be80a885ff936d0663200d0af9957fb2804c043"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "cd858943a366151b1e64ce008750bd52e04ecf8c98ec2882262b308a59bdc70a"
  end

  depends_on "node@22"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
