class Rustowl < Formula
  desc "Visualize Ownership and Lifetimes in Rust"
  homepage "https://github.com/cordx56/rustowl"
  url "https://github.com/cordx56/rustowl/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "e65e5e75ee242dc47110ea78f3e7e83f0f4019999cc57d13183844d518139875"
  license "MPL-2.0"

  depends_on "rustup" => :build

  def install
    ENV["RUSTC_BOOTSTRAP"] = "1"
    ENV["RUSTUP_TOOLCHAIN"] = "1.86.0"
    ENV["CARGO_TARGET_DIR"] = "target"
    ENV["RUSTOWL_RUNTIME_DIRS"] = prefix.to_s

    system "rustup", "component", "add", "rust-src", "rustc-dev", "llvm-tools"

    system "cargo", "install", "--no-default-features", *std_cargo_args

    mkdir_p "rustowl-build-time-out"
    system "find", "target", "-type", "d", "-name", "rustowl-build-time-out", "-exec", "cp", "-r", "{}", "./", ";"

    mkdir_p "sysroot"
    active_toolchain = `rustup show active-toolchain | awk '{ print $1 }'`.strip

    cp_r `rustc --print=sysroot`.strip, "sysroot/#{active_toolchain}"

    Dir.glob("sysroot/**/*").each do |f|
      next if File.directory?(f)
      next if f.match?(/\.(rlib|so|dylib|dll)$/)

      File.delete(f)
    end

    dirs_deleted = true
    while dirs_deleted
      dirs_deleted = false
      Dir.glob("sysroot/**/*").select { |d| File.directory?(d) }.sort_by { |d| -d.count("/") }.each do |d|
        if Dir.empty?(d)
          Dir.rmdir(d)
          dirs_deleted = true
        end
      end
    end

    bin.install "target/release/rustowl"
    bin.install "target/release/rustowlc"
    prefix.install_metafiles

    prefix.install "sysroot"

    man1.install "rustowl-build-time-out/man/rustowl.1"
    bash_completion.install "rustowl-build-time-out/completions/rustowl.bash" => "rustowl"
    zsh_completion.install "rustowl-build-time-out/completions/_rustowl"
    fish_completion.install "rustowl-build-time-out/completions/rustowl.fish"
  end

  test do
    system bin/"rustowl", "--version"
  end
end
