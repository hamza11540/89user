import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:Rider/src/helper/helper.dart';
import 'package:Rider/src/helper/assets.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:Rider/src/controllers/ride_controller.dart';
import 'package:Rider/src/helper/dimensions.dart';
import 'package:Rider/src/helper/styles.dart';
import 'package:Rider/src/models/ride.dart';
import 'package:Rider/src/models/payment_gateway_enum.dart';
import 'package:Rider/src/models/screen_argument.dart';
import '../webview.dart';

class MercadoPagoPaymentWidget extends StatefulWidget {
  final Ride ride;
  const MercadoPagoPaymentWidget(this.ride, {Key? key}) : super(key: key);

  @override
  _MercadoPagoPaymentWidgetState createState() =>
      _MercadoPagoPaymentWidgetState();
}

class _MercadoPagoPaymentWidgetState
    extends StateMVC<MercadoPagoPaymentWidget> {
  late RideController _con;
  Timer? timer;

  _MercadoPagoPaymentWidgetState() : super(RideController()) {
    _con = controller as RideController;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void checkPayment() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _con.doCheckPaymentStatus(widget.ride).then((hasChanged) {
        if (hasChanged) {
          timer.cancel();
          Navigator.pushReplacementNamed(
            context,
            '/Ride',
            arguments: ScreenArgument(
              {
                'rideId': widget.ride.id,
              },
            ),
          );
        }
      }).catchError((onError) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _con.loadingPreference
          ? () {}
          : () async {
              checkPayment();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    Helper.getUri('rides/${widget.ride.id}/payWithMercadoPago')
                        .toString(),
                    widget.ride.id,
                  ),
                ),
              );
            },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: Size(MediaQuery.of(context).size.width, 50),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: _con.loadingPreference
          ? CircularProgressIndicator(
              color: Theme.of(context).highlightColor,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.mercadoPago,
                  width: 40,
                  height: 40,
                ),
                SizedBox(
                  width: 15,
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.payWith(
                    PaymentGatewayEnumHelper.description(
                      PaymentGatewayEnum.mercado_pago,
                      context,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: khulaBold.merge(
                    TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
