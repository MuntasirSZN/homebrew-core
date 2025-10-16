class Hugo < Formula
  desc "Configurable static site generator"
  homepage "https://gohugo.io/"
  url "https://github.com/gohugoio/hugo/archive/refs/tags/v0.151.1.tar.gz"
  sha256 "7750d644c5ea762ba400001d753a9d37dc4f1467ca470f01cffff2b2a87c9232"
  license "Apache-2.0"
  head "https://github.com/gohugoio/hugo.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2cde038d603403adba49a54a232fb8687b25e90fcada5746465583d39527286b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7068f41eeb23c6f6b53042a809136a86cf3b08fe397ff1c3c18a639337096b48"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d05a40fa03422de8264ed26eb694372239b74bdab79c4bd3c94ca3869cc91902"
    sha256 cellar: :any_skip_relocation, sonoma:        "b5b9c5822d6f6953325bb193a79d782d928bed73046ba9a8e9e3c7d9580fb928"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "184943146e1aad23dc82ba25547c2259ee51e350a793ffe282fea90fefda4a0b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7802a36236a93cfd992f03b8a716ac6d200bff09df21775b60d3dde4d46453b6"
  end

  depends_on "go" => :build

  def install
    # Needs CGO (which is disabled by default on Linux Arm)
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -s -w
      -X github.com/gohugoio/hugo/common/hugo.commitHash=#{tap.user}
      -X github.com/gohugoio/hugo/common/hugo.buildDate=#{time.iso8601}
      -X github.com/gohugoio/hugo/common/hugo.vendorInfo=brew
    ]
    tags = %w[extended withdeploy]
    system "go", "build", *std_go_args(ldflags:, tags:)

    generate_completions_from_executable(bin/"hugo", "completion")
    system bin/"hugo", "gen", "man", "--dir", man1
  end

  test do
    site = testpath/"hops-yeast-malt-water"
    system bin/"hugo", "new", "site", site
    assert_path_exists site/"hugo.toml"

    assert_match version.to_s, shell_output("#{bin}/hugo version")
  end
end
