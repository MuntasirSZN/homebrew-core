class Beautysh < Formula
  include Language::Python::Virtualenv

  desc "Bash beautifier"
  homepage "https://github.com/lovesegfault/beautysh"
  url "https://files.pythonhosted.org/packages/f9/fe/5ee6d507a194b9a321f3489b75660e6a611721d237906e4e0c9b67bcb380/beautysh-6.3.3.tar.gz"
  sha256 "a86e1ea1bc42c9251eb2543403156356805b0983f29b4139b5cc27f270f963a7"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "a2e483466ead879c0fec54ec23b676a33657d90ac8f4802a15eb06da9c6660b1"
  end

  depends_on "python@3.14"

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/d8/53/6f443c9a4a8358a93a6792e2acffb9d9d5cb0a5cfd8802644b7b1c9a02e4/colorama-0.4.6.tar.gz"
    sha256 "08695f5cb7ed6e0531a20572697297273c47b8cae5a63ffc6d6ed5c201be6e44"
  end

  resource "editorconfig" do
    url "https://files.pythonhosted.org/packages/88/3a/a61d9a1f319a186b05d14df17daea42fcddea63c213bcd61a929fb3a6796/editorconfig-0.17.1.tar.gz"
    sha256 "23c08b00e8e08cc3adcddb825251c497478df1dada6aefeb01e626ad37303745"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    test_file = testpath/"test.sh"
    test_file.write <<~SHELL
      #!/bin/bash
          echo "Hello, World!"
    SHELL

    system bin/"beautysh", test_file

    assert_equal <<~SHELL, test_file.read
      #!/bin/bash
      echo "Hello, World!"
    SHELL

    assert_match version.to_s, shell_output("#{bin}/beautysh --version")
  end
end
