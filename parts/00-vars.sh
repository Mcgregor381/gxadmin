GXADMIN_SITE_SPECIFIC=${GXADMIN_SITE_SPECIFIC:-~/.config/gxadmin-local.sh}

hexencodefield9=$(cat <<EOF
import csv
import binascii
import sys
csv.field_size_limit(sys.maxsize)


spamreader = csv.reader(sys.stdin, delimiter=',', quotechar='"')
spwamwrite = csv.writer(sys.stdout, delimiter=',', quotechar='"')

for row in spamreader:
	if row[9][0] != "\\\\":
		row[9] = "\\\\x" + binascii.hexlify(row[9])
	spwamwrite.writerow(row)
EOF
)

identicon_script=$(cat <<EOF
import sys
import hashlib

def colored(fg, bg, value):
	return '\x1b[38;5;{0}m\x1b[48;5;{1}m{2}\x1b[0m'.format(fg, bg, value)

class Iden:
	def build(self, h):
		pixels = [[0 for _ in range(5)] for _ in range(5)]
		for i in range(0, 5):
			for x in range(0, 5):
				pixels[x][i] = self.showPixel(i, x, h)
		return pixels

	def showPixel(self, x, y, h):
		m = 6 + abs(2-x) * 5 + y
		return int(h[m:m+1], 16) % 2 == 0

	def getIcon(self, num, hash_string):
		for x in self.build(hash_string):
			yield ''.join([
				colored(num, num + 15 % 255, '██' if q else '  ')
				for q in x
			])

data = sys.stdin.read().strip()
m = hashlib.sha256()
m.update(data.encode('UTF-8'))
hash_string = m.hexdigest()
num = int(hash_string[0:2], 16)
for line in Iden().getIcon(num, hash_string):
	print(line)
EOF
)
