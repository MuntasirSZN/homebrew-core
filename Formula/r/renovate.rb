class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-41.107.0.tgz"
  sha256 "5f031dcd3b2330b24771087bdbe3793fc6d6febd258db48a684e865ea2034048"
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
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "37b65335698bcce33b63929bbedb2e919ea7a75cd8050f58e88575757945464a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4d74a4f7366da5090ebb8443a74dc2651e1f91c65de44f31af61312de805ff0f"
    sha256 cellar: :any_skip_relocation, sonoma:        "14d8a631e0fe5557f420cd32faf9345ca59caf322fd8c1cd0c36eb43236bb162"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "5184f00bb89c892942fc056f8c63030e9fb86a2d00f9854ac754dea08513cd4c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "26c9151cb149d6635c67c112a1866210d4324a8ab1b02f76a210883ac4082055"
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
