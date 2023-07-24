import 'package:flutter/cupertino.dart';

class CalculateAnesthesiaPage extends StatefulWidget {
  @override
  _CalculateAnesthesiaPageState createState() =>
      _CalculateAnesthesiaPageState();
}

class _CalculateAnesthesiaPageState extends State<CalculateAnesthesiaPage> {
  TextEditingController _bodyWeightController = TextEditingController();
  String _atropineResult = '';
  String _ketamineResult = '';
  String _xylazineResult = '';
  String _diazepamResult = '';
  bool _showResults = false;
  bool _showDisclaimer = true;

  @override
  void dispose() {
    _bodyWeightController.dispose();
    super.dispose();
  }

  void _calculate() {
    double bw = double.tryParse(_bodyWeightController.text) ?? 0.0;

    double atropine = bw * 0.02 / 0.6;
    double ketamine = bw * 7 / 50;
    double xylazine = bw * 0.5 / 20;
    double diazepam = bw * 0.5 / 5;

    setState(() {
      _atropineResult = atropine.toStringAsFixed(2);
      _ketamineResult = ketamine.toStringAsFixed(2);
      _xylazineResult = xylazine.toStringAsFixed(2);
      _diazepamResult = diazepam.toStringAsFixed(2);
      _showResults = true;
      _showDisclaimer = false;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Anesthesia Calculation Results'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultItem(
                  'Atropine sulphate', _atropineResult, 'bw X 0.02÷0.6'),
              _buildResultItem('Ketamine', _ketamineResult, 'bw X 7÷50'),
              _buildResultItem('Xylazine', _xylazineResult, 'bw X 0.5÷20'),
              _buildResultItem('Diazepam', _diazepamResult, 'bw X 0.5÷5'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showResults = false;
                  _showDisclaimer = true;
                  _bodyWeightController.text = '';
                });
              },
              child: Text('Close'),
              isDestructiveAction: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(String label, String value, String calculation) {
    final double bw = double.tryParse(_bodyWeightController.text) ?? 0.0;
    final String updatedCalculation =
        calculation.replaceAll('bw', bw.toStringAsFixed(2));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label = $updatedCalculation = $value ml',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoTextField(
                controller: _bodyWeightController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18.0),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                placeholder: 'Body Weight (in kg)',
                placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
              ),
              SizedBox(height: 16.0),
              CupertinoButton.filled(
                onPressed: _calculate,
                child: Text('Calculate', style: TextStyle(fontSize: 18.0)),
              ),
              SizedBox(height: 24.0),
              if (_showDisclaimer)
                Text(
                  'Disclaimer: This calculation is for veterinary use only. Consult a professional for accurate dosage information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
