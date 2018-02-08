using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686),
    BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build libreadstat
sources = [
    "https://github.com/WizardMac/ReadStat.git" =>
    "8472131f5cb5d5882f05f1fc784bf9dbb501272a",
]

script = raw"""
cd $WORKSPACE/srcdir
cd ReadStat/
./autogen.sh
if [ $target = "x86_64-w64-mingw32" ] || [ $target = "i686-w64-mingw32" ]; then ./configure --prefix=/ --host=$target CFLAGS="-I$DESTDIR/include" LDFLAGS="-L$DESTDIR/lib"; else ./configure --prefix=/ --host=$target; fi
make
make install

"""

products = prefix -> [
    ExecutableProduct(prefix,"readstat"),
    LibraryProduct(prefix,"libreadstat")
]

dependencies = [
"https://github.com/davidanthoff/IConvBuilder/releases/download/v1.15%2Bbuild.1/build.jl"]

# Build the given platforms using the given sources
hashes = autobuild(pwd(), "libreadstat", platforms, sources, script, products, dependencies=dependencies)

if !isempty(get(ENV,"TRAVIS_TAG",""))
    print_buildjl(pwd(), products, hashes,
        "https://github.com/davidanthoff/ReadStatBuilder/releases/download/$(ENV["TRAVIS_TAG"])")
end

