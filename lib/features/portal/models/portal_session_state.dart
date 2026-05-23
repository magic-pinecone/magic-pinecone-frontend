enum PortalSessionStatus {
  expired,
  authenticating,
  authenticated,
  requireReauthentication,
  error,
}

class PortalSessionState {
  const PortalSessionState({required this.status, this.token});

  const PortalSessionState.expired()
    : status = PortalSessionStatus.expired,
      token = null;

  final PortalSessionStatus status;
  final String? token;

  bool get isAuthenticated =>
      status == PortalSessionStatus.authenticated &&
      token != null &&
      token!.isNotEmpty;

  PortalSessionState copyWith({
    PortalSessionStatus? status,
    String? token,
    bool clearToken = false,
  }) {
    return PortalSessionState(
      status: status ?? this.status,
      token: clearToken ? null : (token ?? this.token),
    );
  }
}
