class N8nMcp < Formula
  desc "MCP for Claude Desktop, Claude Code, Windsurf, Cursor to build n8n workflows"
  homepage "https://www.n8n-mcp.com/"
  url "https://registry.npmjs.org/n8n-mcp/-/n8n-mcp-2.20.0.tgz"
  sha256 "7dd3424cdf32077e57b31d03a2a4ae5033e8f606ae0bb5d3d450d643cc1f6ca9"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2df423717d3db71696ba4ae0ef6fe18f497f0c293ff934a6cfd959a9df106393"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f2ff03cb0ccfe5df59b610d2ba27f4e9eca53c2fee57397f1555411dec3033cb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "1f184f83ec644d24e75753b9625e25f9ea4efade03eb816df992597a378b3d6b"
    sha256 cellar: :any_skip_relocation, sonoma:        "f0b49e4e3a3ad0ccfed6b9877e82cd223ada1f59cd504f98edabaa6c71bc5215"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0b585c3e0b93b5ea6be7fde43e2b7ab789955477430e592013dde8414adcabc2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fafc742e9004d1a9bf40daecd2f8d57fc83b1f3f3deadd61c0aff04c2cc8f011"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    ENV["N8N_API_URL"] = "https://your-n8n-instance.com"
    ENV["N8N_API_KEY"] = "your-api-key"

    output_log = testpath/"output.log"
    pid = spawn bin/"n8n-mcp", testpath, [:out, :err] => output_log.to_s
    sleep 10
    sleep 5 if OS.mac? && Hardware::CPU.intel?
    assert_match "n8n Documentation MCP Server running on stdio transport", output_log.read
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
