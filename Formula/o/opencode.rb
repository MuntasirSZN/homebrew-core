class Opencode < Formula
  desc "AI coding agent, built for the terminal"
  homepage "https://opencode.ai"
  url "https://registry.npmjs.org/opencode-ai/-/opencode-ai-0.15.4.tgz"
  sha256 "42e1fd6db2c6845230cfc26bad0b067afb8e5b2dd9bbef0a523b56662715c542"
  license "MIT"

  bottle do
    sha256                               arm64_tahoe:   "a674c44c9ba579b2e449bba41c22aea9c27056b3e7c3b80b400c5d3a79b63c9d"
    sha256                               arm64_sequoia: "a674c44c9ba579b2e449bba41c22aea9c27056b3e7c3b80b400c5d3a79b63c9d"
    sha256                               arm64_sonoma:  "a674c44c9ba579b2e449bba41c22aea9c27056b3e7c3b80b400c5d3a79b63c9d"
    sha256 cellar: :any_skip_relocation, sonoma:        "d7812c56e4494d548efc2facbdebb36f803fd5ba99504fc8cf45b25f72da5611"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9f28eaaf0226243c3ddd27f10dadcb57cee571d8a0909dfaa250a7e643f89deb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "50b951fda2951481a906352f054ff3bcb96eaef8fb23a2048f6962dede7e71a5"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/opencode --version")
    assert_match "opencode", shell_output("#{bin}/opencode models")
  end
end
