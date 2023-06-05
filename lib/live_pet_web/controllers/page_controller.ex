defmodule LivePetWeb.PageController do
  use LivePetWeb, :controller

  def home(conn, _params) do
    # Redirect to the appropriate page
    redirect_user(conn)
  end

  defp redirect_user(%{assigns: %{current_user: nil}} = conn) do
    redirect(conn, to: ~p"/users/log_in")
  end

  defp redirect_user(%{assigns: %{current_user: _}} = conn) do
    redirect(conn, to: ~p"/pets")
  end
end
