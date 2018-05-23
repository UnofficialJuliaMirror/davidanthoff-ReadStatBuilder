using BinaryBuilder

# Collection of sources required to build libreadstat
sources = [
    "https://github.com/WizardMac/ReadStat.git" =>
    "7bced5b279486b92f362d97aa671241e787a809a",
]

script = raw"""
cd $WORKSPACE/srcdir
cd ReadStat/
./autogen.sh
if [ $target = "x86_64-w64-mingw32" ] || [ $target = "i686-w64-mingw32" ]; then ./configure --prefix=${prefix} --host=${target} CFLAGS="-I$DESTDIR/include" LDFLAGS="-L$DESTDIR/lib"; else ./configure --prefix=${prefix} --host=${target}; fi
make
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line.
platforms = [
    # Windows
    Windows(:i686),
    Windows(:x86_64),

    # Hello linux my old friend
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc),
    Linux(:powerpc64le, :glibc),

    # Add some musl love
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),

    # The BSD's (FreeBSD put on hold until we fix the -fPIC debacle)
    #FreeBSD(:x86_64),
    MacOS(),
]

dependencies = [
    "https://github.com/davidanthoff/IConvBuilder/releases/download/v1.15%2Bbuild.2/build.jl"
]

products = prefix -> [
    ExecutableProduct(prefix,"readstat", :readstat),
    LibraryProduct(prefix,"libreadstat", :libreadstat)
]

build_tarballs(ARGS, "ReadStat", sources, script, platforms, products, dependencies)
