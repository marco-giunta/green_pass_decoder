from base45 import b45decode
from zlib import decompress
from flynn import decoder

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

if __name__ == '__main__':
    main()
