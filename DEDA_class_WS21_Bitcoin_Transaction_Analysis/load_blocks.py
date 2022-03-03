from blockchain_parser.blockchain import Blockchain
from databaseWriter import DatabaseWriter
import time


path = '/media/sf_blocks'
blockchain = Blockchain(path)
api = DatabaseWriter()
tic = time.time()
blocks = blockchain.get_unordered_blocks()
start = 8000
stop = 8000
for block_num in range(stop):
    block = next(blocks)
    if block_num >= start - 1:
        print("Block {}".format(block_num+1))
        api.add_block(block)


toc = time.time() - tic

print("It took {}s for {} transaction. {} average".format(toc, stop-start+1, toc/(stop-start+1)))

