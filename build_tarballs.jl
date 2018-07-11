using BinaryBuilder

# Collection of sources required to build libreadstat
sources = [
    "https://github.com/WizardMac/ReadStat.git" =>
    "68d7a59a503466f23501bf85a7c515626a1af0ff",
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
platforms = supported_platforms()

dependencies = [
    "https://github.com/davidanthoff/IConvBuilder/releases/download/v1.15%2Bbuild.3/build.jl"
]

products = prefix -> [
    ExecutableProduct(prefix,"readstat", :readstat),
    LibraryProduct(prefix,"libreadstat", :libreadstat)
]

build_tarballs(ARGS, "ReadStat", sources, script, platforms, products, dependencies)
