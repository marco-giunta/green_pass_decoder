from base45 import b45decode
from zlib import decompress
from flynn import decoder
from datetime import datetime

def green_pass_decoder(qr_code_string):
    # https://git.gir.st/greenpass.git/blob_plain/master:/greenpass.py
    qr_code_string = qr_code_string[4:]
    x = b45decode(qr_code_string)
    y = decompress(x)
    (_, (headers1, headers2, cbor_data,signature)) = decoder.loads(y)
    decoded_data = decoder.loads(cbor_data)
    return decoded_data

def main():
    qr_code_string = open('./qr_code.txt', 'r').read().strip()
    print(green_pass_decoder(qr_code_string))

    data = green_pass_decoder(qr_code_string)
    date = lambda ts: datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    print("QR Code Issuer :", data[1])
    print("QR Code Expiry :", date(data[4]))
    print("QR Code Generated :", date(data[6]))

if __name__ == '__main__':
    main()
