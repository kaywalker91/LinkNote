"""LinkNote favicon 래스터라이저 — 산출물은 site/favicon.ico, site/apple-touch-icon.png.

빌드 소스이므로 tool/ 에 둔다 (tool/og-cover.html 과 같은 규약).
site/favicon.svg 는 손으로 관리하며 여기 상수와 형태가 같아야 한다.

  재현 절차 — **저장소 루트에서** 실행. 출력은 바이트 단위로 재현된다.

    python3 tool/gen_favicon.py site

마크는 사이트 nav(.nav-brand .dot)·OG 커버(.brand .dot)와 같은
forest 그린 dot + halo ring 이다. 앱 런처 아이콘(assets/images/app_icon.png)은
"LinkNote" 워드마크라 16px 에서 판독이 불가능해 쓰지 않는다.

PIL/ImageMagick/rsvg 가 이 머신에 없어 PNG/ICO 컨테이너를 직접 조립한다.
표준 라이브러리(zlib, struct)만 쓰므로 CI 에서도 추가 설치 없이 돈다.
"""
import struct, zlib, sys

GROUND = (0x0D, 0x12, 0x0F)
FOREST = (0x4B, 0xBD, 0x80)

R_CORNER = 0.18   # 라운드 사각형 코너 반경 (타일 크기 비율)
R_DOT    = 0.20   # dot 반경
R_RING_I = 0.255  # halo 안쪽 반경
R_RING_O = 0.35   # halo 바깥 반경
RING_A   = 0.30   # halo 알파

SS = 4  # 픽셀당 supersampling 격자


def _inside_round_rect(x, y, r):
    """단위 정사각형 [0,1]^2 의 라운드 사각형 내부 판정."""
    cx = min(max(x, r), 1.0 - r)
    cy = min(max(y, r), 1.0 - r)
    dx, dy = x - cx, y - cy
    return dx * dx + dy * dy <= r * r


def render(size, rounded=True, opaque=False):
    """size x size RGBA 바이트열 (행 우선) 을 만든다."""
    px = bytearray()
    step = 1.0 / (size * SS)
    for py in range(size):
        for pxi in range(size):
            g_cov = ring_cov = dot_cov = 0
            for sy in range(SS):
                for sx in range(SS):
                    u = (pxi * SS + sx + 0.5) * step
                    v = (py * SS + sy + 0.5) * step
                    if rounded and not _inside_round_rect(u, v, R_CORNER):
                        continue
                    g_cov += 1
                    du, dv = u - 0.5, v - 0.5
                    d2 = du * du + dv * dv
                    if d2 <= R_DOT * R_DOT:
                        dot_cov += 1
                    elif R_RING_I * R_RING_I <= d2 <= R_RING_O * R_RING_O:
                        ring_cov += 1
            n = SS * SS
            a_ground = g_cov / n
            if a_ground == 0:
                px += b"\x00\x00\x00\x00"
                continue
            # ground 위에 ring, dot 순으로 합성
            col = list(GROUND)
            for cov, alpha in ((ring_cov / n, RING_A), (dot_cov / n, 1.0)):
                a = cov * alpha
                if a:
                    col = [c * (1 - a) + f * a for c, f in zip(col, FOREST)]
            a_out = 255 if opaque else round(a_ground * 255)
            px += bytes(int(round(c)) for c in col) + bytes([a_out])
    return bytes(px)


def png(size, raw):
    def chunk(tag, data):
        c = tag + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c))

    stride = size * 4
    scan = b"".join(b"\x00" + raw[y * stride:(y + 1) * stride] for y in range(size))
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(scan, 9))
            + chunk(b"IEND", b""))


def ico(pngs):
    """PNG-embedded ICO (모든 최신 브라우저 지원)."""
    out = struct.pack("<HHH", 0, 1, len(pngs))
    offset = 6 + 16 * len(pngs)
    entries, blobs = b"", b""
    for size, blob in pngs:
        entries += struct.pack("<BBBBHHII", size & 0xFF, size & 0xFF, 0, 0,
                               1, 32, len(blob), offset)
        offset += len(blob)
        blobs += blob
    return out + entries + blobs


if __name__ == "__main__":
    site = sys.argv[1]
    sizes = [16, 32, 48]
    with open(f"{site}/favicon.ico", "wb") as f:
        f.write(ico([(s, png(s, render(s))) for s in sizes]))
    # iOS 홈 화면 아이콘은 OS 가 자체 마스크를 씌우므로 full-bleed 불투명으로 낸다.
    with open(f"{site}/apple-touch-icon.png", "wb") as f:
        f.write(png(180, render(180, rounded=False, opaque=True)))
    print("ok")
