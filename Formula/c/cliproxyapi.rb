class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  url "https://github.com/router-for-me/CLIProxyAPI/archive/refs/tags/v6.2.16.tar.gz"
  sha256 "2745a2704774b08162c605091f5ec6089c84f196b6e10794c2056b023a5b0a5e"
  license "MIT"

  bottle do
    sha256                               arm64_tahoe:   "15b767ad4e85cab8fcc236fff5b6a495934dfffb25e0aa9c9b68f690339cf77a"
    sha256                               arm64_sequoia: "15b767ad4e85cab8fcc236fff5b6a495934dfffb25e0aa9c9b68f690339cf77a"
    sha256                               arm64_sonoma:  "15b767ad4e85cab8fcc236fff5b6a495934dfffb25e0aa9c9b68f690339cf77a"
    sha256 cellar: :any_skip_relocation, sonoma:        "c7f118741c206f6a79bd9c7392a571a5fdaedce3cc733aecf62dadc95618ddaf"
    sha256                               arm64_linux:   "477ab8d1acd907fc451a28e6a64e87d9fbd2effc8662565cbd009adfbbcb816f"
    sha256                               x86_64_linux:  "641792268aca688bc5a1542a10c6f6f40f3f69405601f71e43299dc8f22050d5"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
      -X main.Commit=#{tap.user}
      -X main.BuildDate=#{time.iso8601}
      -X main.DefaultConfigPath=#{etc/"cliproxyapi.conf"}
    ]

    system "go", "build", *std_go_args(ldflags:), "cmd/server/main.go"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
  end

  service do
    run [opt_bin/"cliproxyapi"]
    keep_alive true
  end

  test do
    require "pty"
    PTY.spawn(bin/"cliproxyapi", "-login", "-no-browser") do |r, _w, pid|
      sleep 5
      Process.kill "TERM", pid
      assert_match "accounts.google.com", r.read_nonblock(1024)
    end
  end
end
