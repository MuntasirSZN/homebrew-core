class Vineyard < Formula
  desc "In-memory immutable data manager. (Project under CNCF)"
  homepage "https://v6d.io"
  url "https://github.com/v6d-io/v6d/releases/download/v0.24.4/v6d-0.24.4.tar.gz"
  sha256 "055bab09ca67542ccb13229de8c176b7875b4ba8c8a818e942218dccc32a6bae"
  license "Apache-2.0"
  revision 1

  bottle do
    rebuild 1
    sha256                               arm64_sequoia: "2e2a8b3c0f90b05b531b357b9da1061516dd3ba6915f0680fc263d7b03f23a2d"
    sha256                               arm64_sonoma:  "ba79f2038774c01fab222ed48ad612d63f84576cb73cd8dcf98bac1fc0c1a774"
    sha256                               arm64_ventura: "79c267dcc2351e82975c128655dfaf51837cbba3e58e83f3704ed247c9b2751e"
    sha256                               sonoma:        "dd6db36a0a41a9a09d9a06c4478ca7cdbfc92289a104b30eef548c4264faf75e"
    sha256                               ventura:       "f65107ae26822b775805252e697d8f440c2f88bf214638f3423e64305dcdf905"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fcc0b596e56cfc398d706ad00be490490ed117d238df83a5ca6af8dba213e7f9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "369ebc7d9049af8247bcba826f2810d3d8a2e1f639431b93dd681211df330743"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "llvm" => :build # for clang Python bindings
  depends_on "openssl@3" => :build # indirect (not linked) but CMakeLists.txt checks for it
  depends_on "python-setuptools" => :build
  depends_on "python@3.13" => :build
  depends_on "apache-arrow"
  depends_on "boost"
  depends_on "cpprestsdk"
  depends_on "etcd"
  depends_on "etcd-cpp-apiv3"
  depends_on "gflags"
  depends_on "glog"
  depends_on "libgrape-lite"
  depends_on "open-mpi"

  on_linux do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # apache-arrow 21.0.0 support
  # https://github.com/v6d-io/v6d/pull/2052
  patch do
    url "https://github.com/v6d-io/v6d/commit/cab3ed986e15464d6b544a98bac4db38d0e89e3a.patch?full_index=1"
    sha256 "ce1325c893f210a3eae9ff29a8ab6cfa377d6672ab260db58de8522857856206"
  end

  def install
    # Workaround to support Boost 1.87.0+ until upstream fix for https://github.com/v6d-io/v6d/issues/2041
    boost_asio_post_files = %w[
      src/server/async/socket_server.cc
      src/server/server/vineyard_server.cc
      src/server/services/etcd_meta_service.cc
      src/server/services/local_meta_service.cc
      src/server/services/local_meta_service.h
      src/server/services/meta_service.cc
    ]
    inreplace boost_asio_post_files, /^(\s*)(\S+)\.post\(/, "\\1boost::asio::post(\\2,"
    inreplace "src/server/services/etcd_meta_service.cc", "backoff_timer_->cancel(ec);", "backoff_timer_->cancel();"

    # Workaround to support Boost 1.88.0+
    # TODO: Try upstreaming fix along with above
    boost_process_files = %w[
      src/server/util/etcd_launcher.cc
      src/server/util/etcd_member.cc
      src/server/util/kubectl.cc
      src/server/util/proc.cc
      src/server/util/proc.h
      src/server/util/redis_launcher.h
    ]
    inreplace boost_process_files, '#include "boost/process.hpp"', ""
    inreplace "src/server/util/etcd_launcher.h", '#include "boost/process/child.hpp"', ""
    ENV.append "CXXFLAGS", "-std=c++17"
    ENV.append "CXXFLAGS", "-DBOOST_PROCESS_VERSION=1"
    headers = %w[args async child env environment io search_path]
    headers.each { |header| ENV.append "CXXFLAGS", "-include boost/process/v1/#{header}.hpp" }

    python3 = "python3.13"
    # LLVM is keg-only.
    llvm = deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+)?$/) }
    ENV.prepend_path "PYTHONPATH", llvm.opt_prefix/Language::Python.site_packages(python3)

    args = [
      "-DBUILD_VINEYARD_PYTHON_BINDINGS=OFF",
      "-DBUILD_VINEYARD_TESTS=OFF",
      "-DCMAKE_CXX_STANDARD=17",
      "-DCMAKE_CXX_STANDARD_REQUIRED=TRUE",
      "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON", # for newer protobuf
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
      "-DLIBGRAPELITE_INCLUDE_DIRS=#{Formula["libgrape-lite"].opt_include}",
      "-DOPENSSL_ROOT_DIR=#{Formula["openssl@3"].opt_prefix}",
      "-DPYTHON_EXECUTABLE=#{which(python3)}",
      "-DUSE_EXTERNAL_ETCD_LIBS=ON",
      "-DUSE_EXTERNAL_HIREDIS_LIBS=ON",
      "-DUSE_EXTERNAL_REDIS_LIBS=ON",
      "-DUSE_LIBUNWIND=OFF",
    ]
    args << "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-dead_strip_dylibs" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Replace `open-mpi` Cellar path that breaks on `open-mpi` version/revision bumps.
    # CMake FindMPI uses REALPATH so there isn't a clean way to handle during generation.
    openmpi = Formula["open-mpi"]
    inreplace lib/"cmake/vineyard/vineyard-targets.cmake", openmpi.prefix.realpath, openmpi.opt_prefix
  end

  test do
    (testpath/"test.cc").write <<~CPP
      #include <iostream>
      #include <memory>

      #include <vineyard/client/client.h>

      int main(int argc, char **argv) {
        vineyard::Client client;
        VINEYARD_CHECK_OK(client.Connect(argv[1]));

        std::shared_ptr<vineyard::InstanceStatus> status;
        VINEYARD_CHECK_OK(client.InstanceStatus(status));
        std::cout << "vineyard instance is: " << status->instance_id << std::endl;

        return 0;
      }
    CPP

    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.5)

      project(vineyard-test LANGUAGES C CXX)

      find_package(vineyard REQUIRED)

      add_executable(vineyard-test ${CMAKE_CURRENT_SOURCE_DIR}/test.cc)
      target_include_directories(vineyard-test PRIVATE ${VINEYARD_INCLUDE_DIRS})
      target_link_libraries(vineyard-test PRIVATE ${VINEYARD_LIBRARIES})
    CMAKE

    # Remove Homebrew's lib directory from LDFLAGS as it is not available during
    # `shell_output`.
    ENV.remove "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"

    vineyard_sock = testpath/"vineyard.sock"
    # prepare vineyardd
    vineyardd_pid = spawn bin/"vineyardd", "--norpc",
                                           "--meta=local",
                                           "--socket=#{vineyard_sock}"

    # sleep to let vineyardd get its wits about it
    sleep 10 until vineyard_sock.exist? && vineyard_sock.socket?

    assert_equal("vineyard instance is: 0\n",
                 shell_output("#{testpath}/build/vineyard-test #{vineyard_sock}"))
  ensure
    # clean up the vineyardd process before we leave
    Process.kill("HUP", vineyardd_pid)
  end
end
