from __main__ import app

@app.route('/test', methods=['GET'])
def test():
    return 'it works!'
