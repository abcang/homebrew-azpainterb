class Azpainterb < Formula
  desc 'Simple full-color painting software for versatile use such as dot picture editing, illustration, and retouching.'
  homepage 'https://github.com/abcang/homebrew-azpainterb'
  url 'https://gitlab.com/azelpg/azpainterb/-/archive/v1.1.3/azpainterb-v1.1.3.tar.gz'
  sha256 'e5c1882c1ec9ad4bed613910383469df49f5ed938de938a52a4cd28b695f918d'
  revision 1

  depends_on 'libpng'
  depends_on 'jpeg-turbo'
  depends_on 'svg2png' => :build
  depends_on 'pkg-config' => :build

  uses_from_macos 'zlib'

  def install
    # NOTE: https://github.com/Homebrew/brew/commit/4836ea0ba2119619697af87edf5fdb2280e90238
    ENV.append_path 'PKG_CONFIG_PATH', '/opt/X11/lib/pkgconfig'
    ENV.prepend_path 'HOMEBREW_INCLUDE_PATHS', '/opt/X11/include'
    ENV.prepend_path 'HOMEBREW_INCLUDE_PATHS', '/opt/X11/include/freetype2'
    ENV.prepend_path 'HOMEBREW_LIBRARY_PATHS', '/opt/X11/lib'

    system './configure', "--prefix=#{prefix}", 'LIBS=-lxi -lz'
    system 'make'
    system 'make', 'install'

    app_name = `sed -n '/^Name=/s///p' desktop/azpainterb.desktop`.chomp + '.app'
    locale = `defaults read -g AppleLocale | sed 's/@.*$$//g'`.chomp + '.UTF-8'
    system %(echo 'do shell script "LANG=#{locale} #{bin}/azpainterb >/dev/null 2>&1 &"' | osacompile -o #{app_name})

    tmp_icon_png = '/tmp/azpainterb_1024.png'
    system 'svg2png', 'desktop/azpainterb.svg', tmp_icon_png
    mkdir_p '/tmp/azpainterb.iconset'
    system 'sips', '-z', '16', '16',   tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_16x16.png'
    system 'sips', '-z', '32', '32',   tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_16x16@2x.png'
    system 'sips', '-z', '32', '32',   tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_32x32.png'
    system 'sips', '-z', '64', '64',   tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_32x32@2x.png'
    system 'sips', '-z', '128', '128', tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_128x128.png'
    system 'sips', '-z', '256', '256', tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_128x128@2x.png'
    system 'sips', '-z', '256', '256', tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_256x256.png'
    system 'sips', '-z', '512', '512', tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_256x256@2x.png'
    system 'sips', '-z', '512', '512', tmp_icon_png, '--out', '/tmp/azpainterb.iconset/icon_512x512.png'
    cp tmp_icon_png, '/tmp/azpainterb.iconset/icon_512x512@2x.png'
    system 'iconutil', '-c', 'icns', '/tmp/azpainterb.iconset'
    cp '/tmp/azpainterb.icns', "#{app_name}/Contents/Resources/applet.icns"

    rm_rf '/tmp/azpainterb.iconset'
    rm '/tmp/azpainterb.icns'
    rm tmp_icon_png

    prefix.install app_name
  end

  def caveats
    <<~EOS
      Please execute this command to register to Launchpad.
        ln -sf $(brew --prefix azpainterb)/AzPainterB.app /Applications/
    EOS
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test azpainter`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system 'false'
  end
end
