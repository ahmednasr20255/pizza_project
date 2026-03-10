import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: user.phoneNumber != null
            ? Text(user.phoneNumber!)
            : null,
      ),
    );
  }
}
