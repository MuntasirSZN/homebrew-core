class Pyright < Formula
  desc "Static type checker for Python"
  homepage "https://github.com/microsoft/pyright"
  url "https://registry.npmjs.org/pyright/-/pyright-1.1.383.tgz"
  sha256 "5b642589390ea96b5a9ae07fd93b8b08a3f23c4aab4f1008c8b48cb8004923c2"
  license "MIT"
  head "https://github.com/microsoft/pyright.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4f59d7f90ae5b5f3773a6b95330249b6bc84ea22db4d6e9d294870e1e23ae91a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4f59d7f90ae5b5f3773a6b95330249b6bc84ea22db4d6e9d294870e1e23ae91a"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "4f59d7f90ae5b5f3773a6b95330249b6bc84ea22db4d6e9d294870e1e23ae91a"
    sha256 cellar: :any_skip_relocation, sonoma:        "50c847331307d4feb8f5bf32cfd81e173c3facedfa229c419aa9a349ebd759c6"
    sha256 cellar: :any_skip_relocation, ventura:       "50c847331307d4feb8f5bf32cfd81e173c3facedfa229c419aa9a349ebd759c6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4f59d7f90ae5b5f3773a6b95330249b6bc84ea22db4d6e9d294870e1e23ae91a"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"broken.py").write <<~EOS
      def wrong_types(a: int, b: int) -> str:
          return a + b
    EOS
    output = pipe_output("#{bin}/pyright broken.py 2>&1")
    assert_match "error: Type \"int\" is not assignable to return type \"str\"", output
  end
end
