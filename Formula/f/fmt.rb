class Fmt < Formula
  desc "Open-source formatting library for C++"
  homepage "https://fmt.dev/"
  url "https://github.com/fmtlib/fmt/releases/download/12.1.0/fmt-12.1.0.zip"
  sha256 "695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7"
  license "MIT"
  head "https://github.com/fmtlib/fmt.git", branch: "master"

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "3945c835bab2530aafbb56eca0a87f7a76d2a0bf5e1201a0f2c3fa1430168e4d"
    sha256 cellar: :any,                 arm64_sequoia: "585f4564a32043378cf78eaf8fe3ad3cd3f30ce25c24a5795204225d2fc62bf2"
    sha256 cellar: :any,                 arm64_sonoma:  "1f162c9569ecb94719bb0f49517c4c2d00470257d8b01943313d85b281724444"
    sha256 cellar: :any,                 arm64_ventura: "7ed66b96daebfc7607ff27cc6901e446a1b7af5bbfdd3b47ab679a59a9506012"
    sha256 cellar: :any,                 sonoma:        "502fee1745aa6a2ef90430867fcb95eaabd4a5051dfb0ba5d70d7240cd5e3be9"
    sha256 cellar: :any,                 ventura:       "3d9198e5324c1f9ed67a4ec185e62cb52f602d09d69cfe4b3c9de0b8ad32f2dc"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cc2dde40b9bf247056284547a03a84d78a4e5e0881fd12b1286b613017151659"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7aec969a40769e65ab0d63abd988f6104a2372c469d002922959e3a414151e70"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=TRUE", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    system "cmake", "-S", ".", "-B", "build-static", "-DBUILD_SHARED_LIBS=FALSE", *std_cmake_args
    system "cmake", "--build", "build-static"
    lib.install "build-static/libfmt.a"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include <string>
      #include <fmt/format.h>
      int main()
      {
        std::string str = fmt::format("The answer is {}", 42);
        std::cout << str;
        return 0;
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++11", "-o", "test",
                  "-I#{include}",
                  "-L#{lib}",
                  "-lfmt"
    assert_equal "The answer is 42", shell_output("./test")
  end
end
