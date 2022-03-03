from blockchain_parser.transaction import Transaction as ParserTx
from blockchain_parser.transaction import Input as ParserIn
from blockchain_parser.transaction import Output as ParserOut


class Transaction:

    def __init__(self, tx: ParserTx):
        self.id = tx.txid
        self.inputs = [Input(p_in, tx.txid) for p_in in tx.inputs]
        self.outputs = [Output(p_out, tx.txid, output_no) for output_no, p_out in enumerate(tx.outputs) if p_out.value > 0]
        self.n_inputs = len(self.inputs)
        self.n_outputs = len(self.outputs)
        self.is_standard = self.check_if_standard()

    def check_if_standard(self):
        for output in self.outputs:
            if not output.is_standard:
                return False

        return True

class Input:

    def __init__(self, input_: ParserIn, tx_to_id: str):
        self.tx_to_id = tx_to_id
        self.tx_from_id = input_.transaction_hash
        self.output_no = input_.transaction_index


class Output:

    def __init__(self, output: ParserOut, tx_from_id: str, output_no: int):
        self.is_standard = output.type != "OP_RETURN"

        if self.is_standard:
            self.tx_from_id = tx_from_id
            self.output_no = output_no
            if not output.addresses:
                self.wallet_id = 'unknown'
            else:
                self.wallet_id = output.addresses[0].address
            self.value = output.value

