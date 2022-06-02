import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/monster.dart';
import '../Resource/action_handler.dart';
import 'line_builder.dart';
import 'menus/main_menu.dart';

double tempScale = 0.8;

class MonsterAbilityCardWidget extends StatefulWidget {
  //final double height;
  //final double borderWidth = 2;
  final MonsterModel data;

  const MonsterAbilityCardWidget({Key? key, required this.data})
      : super(key: key);

  @override
  _MonsterAbilityCardWidgetState createState() =>
      _MonsterAbilityCardWidgetState();

  static Widget buildFront(MonsterAbilityCardModel? card, double scale) {
    String initText = card!.initiative.toString();
    if (initText.length == 1) {
      initText = "0" + initText;
    }

    var shadow = [
      Shadow(
          offset: Offset(1 * scale * tempScale, 1 * scale * tempScale),
          color: Colors.black)
    ];

    return Container(
        key: const ValueKey<int>(1),
        margin: EdgeInsets.all(2 * scale * tempScale),
        width: 180 * tempScale * scale,
        child: Stack(
          //fit: StackFit.passthrough,
          alignment: AlignmentDirectional.center,
          clipBehavior: Clip.none,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0 * scale),
              child: Image(
                height: 123 * tempScale * scale,
                image: const AssetImage(
                    "assets/images/psd/monsterAbility-front.png"),
              ),
            ),
            Positioned(
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    card.title,
                    style: TextStyle(
                        fontFamily: 'Pirata',
                        color: Colors.white,
                        fontSize: 14 * tempScale * scale,
                        shadows: shadow),
                  ),
                ],
              ),
            ),

            //right: 100,
            //alignment: Alignment.topCenter,
            //child:

            Positioned(
                left: 7.0 * tempScale * scale,
                top: 16.0 * tempScale * scale,
                child: Container(
                  child: Text(
                    textAlign: TextAlign.center,
                    initText,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20 * tempScale * scale,
                        shadows: shadow),
                  ),
                )),
            Positioned(
                left: 6.0 * tempScale * scale,
                bottom: 0.5 * tempScale * scale,
                child: Container(
                  child: Text(
                    card.nr.toString(),
                    style: TextStyle(
                        fontFamily: 'Majalla',
                        color: Colors.white,
                        fontSize: 8 * tempScale * scale,
                        shadows: shadow),
                  ),
                )),
            card.shuffle
                ? Positioned(
                    right: 4.0 * tempScale * scale,
                    bottom: 4.0 * tempScale * scale,
                    child: Container(
                      child: Image(
                        height: 123 * tempScale * 0.14 * scale,
                        image: const AssetImage(
                            "assets/images/abilities/shuffle.png"),
                      ),
                    ))
                : Container(),
            Positioned(
              top: 20.0 * tempScale * scale,
              //alignment: Alignment.center,
              child: Container(
                height: 94 * scale * tempScale,
                //width: 176 * scale * tempScale, //prolly unnecessary
                //color: Colors.amber,
                child: createLines(
                    card.lines, false, CrossAxisAlignment.center, scale),
              ),
            )
          ],
        ));
  }

  static Widget buildRear(double scale, int size) {
    return Container(
        key: const ValueKey<int>(0),
        margin: EdgeInsets.all(2 * scale),
        //width: 180*tempScale*scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0 * scale),
              child: Image(
                height: 123 * tempScale * scale,
                image: const AssetImage(
                    "assets/images/psd/MonsterAbility-back.png"),
              ),
            ),
            size >= 0
                ? Positioned(
                    right: 6.0 * tempScale * scale,
                    bottom: 0 * tempScale * scale,
                    child: Container(
                      child: Text(
                        size.toString(),
                        style: TextStyle(
                            fontFamily: 'Majalla',
                            color: Colors.white,
                            fontSize: 16 * tempScale * scale,
                            shadows: [
                              Shadow(
                                  offset: Offset(1 * scale, 1 * scale),
                                  color: Colors.black)
                            ]),
                      ),
                    ))
                : Container(),
          ],
        ));
  }
}

class _MonsterAbilityCardWidgetState extends State<MonsterAbilityCardWidget> {
// Define the various properties with default values. Update these properties
// when the user taps a FloatingActionButton.
//late MonsterData _data;
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, pi / 2);
          return Transform(
            transform: Matrix4.rotationX(value),
            child: widget,
            alignment: Alignment.center,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    return ValueListenableBuilder<RoundState>(
        valueListenable: _gameState.roundState,
        builder: (context, value, child) {
          MonsterAbilityCardModel? card;
          if (_gameState.roundState.value == RoundState.playTurns) {
            card = _gameState.getDeck(widget.data.deck)!.discardPile.peek;
          }

          //get size for back
          var deckk;
          int size = 8;
          for (var deck in _gameState.currentAbilityDecks) {
            if (deck.name == widget.data.deck) {
              size = deck.drawPile.size();
              deckk = deck;
              break;
            }
          }

          return GestureDetector(
            onTap: () {
              //open deck menu
              openDialog(context, AbilityCardMenu(monsterAbilityState: deckk));

              setState(() {});
            },
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: _transitionBuilder,
                layoutBuilder: (widget, list) => Stack(
                      children: [widget!, ...list],
                    ),
                //switchInCurve: Curves.easeInBack,
                //switchOutCurve: Curves.easeInBack.flipped,
                child: _gameState.roundState.value == RoundState.playTurns
                    ? MonsterAbilityCardWidget.buildFront(card, scale)
                    : MonsterAbilityCardWidget.buildRear(scale, size)),
            //AnimationController(duration: Duration(seconds: 1), vsync: 0);
            //CurvedAnimation(parent: null, curve: Curves.easeIn)
            //),
          );
        });
  }
}
