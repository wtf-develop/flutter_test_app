import 'dart:math';

const _chars = 'qwertyuiopasdfghjklzxcvbnm0123456789';
Random _rnd = Random();

String randomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
