# Created by simeshka on GitHub
pkgname=arch-easy-install
pkgver=1.0
pkgrel=1
pkgdesc="One-line Arch installer script (install.sh + desktop.sh)"
arch=('any')
url="https://github.com/simeshka/arch-install"
license=('MIT')
depends=('bash' 'pacman')
source=(
	"$url/raw/main/install.sh"
	"$url/raw/main/desktop.sh"
)
sha256sums=('SKIP' 'SKIP')

package() {
	install -Dm755 "$srcdir/install.sh" "$pkgdir/usr/bin/arch-easy-install"
	install -Dm755 "$srcdir/desktop.sh" "$pkgdir/usr/bin/arch-desktop-install"
}