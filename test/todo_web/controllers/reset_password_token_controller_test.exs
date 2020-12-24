defmodule Todo.ShareBoardTokens.ResetPasswordTokenControllerTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{ResetPasswordToken, User}
  alias Todo.Factory

  setup %{conn: conn} do
    {:ok, user} = Factory.create_user()

    {:ok, conn: conn, user: user}
  end

  describe "new/2" do
    test "returns reset password form", %{conn: conn} do
      conn = get(conn, "reset-password/new")
      assert html_response(conn, 200) =~ "Reset Password"
    end
  end

  describe "create/2" do
    test "with valid params", %{conn: conn, user: user} do
      params = %{
        "reset_password_token" => %{
          "email" => user.email
        }
      }

      post(conn, "reset-password", params)

      new_reset_password_token = Todo.Repo.get_by(ResetPasswordToken, user_id: user.id)
      [reset_password_email_job] = Todo.Repo.all(Todo.JobQueue)

      assert new_reset_password_token.used == false
      assert new_reset_password_token.user_id == user.id
      assert new_reset_password_token.expiry_date < Timex.now() |> Timex.shift(days: 2)

      assert reset_password_email_job.params == %{
               "type" => "Elixir.Todo.Workers.ResetPasswordEmailWorker",
               "token" => new_reset_password_token.token
             }
    end

    test "with invalid email in params", %{conn: conn} do
      params = %{
        "reset_password_token" => %{
          "email" => "random@email.com"
        }
      }

      conn = post(conn, "reset-password", params)

      assert html_response(conn, 200) =~ "User does not exist"
    end
  end

  describe "reset/2" do
    test "with valid token shows reset form", %{
      conn: conn,
      user: user
    } do
      expiry_date = Timex.now() |> Timex.shift(days: 1)
      {:ok, %ResetPasswordToken{token: token}} = Factory.create_reset_password_token(user.id, expiry_date)
      conn = get(conn, "reset-password/reset?token=#{token}")

      assert html_response(conn, 200) =~ "Update Password"
    end

    test "redirects to new with error when expired", %{
      conn: conn,
      user: user
    } do
      expiry_date = Timex.now() |> Timex.shift(days: -1)
      {:ok, %ResetPasswordToken{token: token}} = Factory.create_reset_password_token(user.id, expiry_date)
      conn = get(conn, "reset-password/reset?token=#{token}")
      assert html_response(conn, 200) =~ "Reset password link has expired."
      assert html_response(conn, 200) =~ "Reset password"
    end

    test "redirects to new with error when token already used", %{
      conn: conn,
      user: user
    } do
      expiry_date = Timex.now() |> Timex.shift(days: 1)
      {:ok, %ResetPasswordToken{token: token}} = Factory.create_reset_password_token(user.id, expiry_date, true)
      conn = get(conn, "reset-password/reset?token=#{token}")
      assert html_response(conn, 200) =~ "Reset password link has already been used."
      assert html_response(conn, 200) =~ "Reset password"
    end

    test "redirects to new with error when token doesn't exist", %{
      conn: conn
    } do
      conn = get(conn, "reset-password/reset?token=123")
      assert html_response(conn, 200) =~ "Reset password link is invalid."
      assert html_response(conn, 200) =~ "Reset password"
    end
  end

  describe "update/2" do
    test "with valid token updates user and reset password token", %{
      conn: conn,
      user: user
    } do
      expiry_date = Timex.now() |> Timex.shift(days: 1)
      {:ok, %ResetPasswordToken{token: token}} = Factory.create_reset_password_token(user.id, expiry_date)

      params = %{
        "user" => %{
          "password" => "abc123"
        }
      }

      conn = put(conn, "reset-password/#{token}", params)

      user = Todo.Repo.get_by(User, id: user.id)
      reset_password_token = Todo.Repo.get_by(ResetPasswordToken, token: token)

      assert Argon2.verify_pass("abc123", user.password) == true
      assert reset_password_token.used == true
      assert redirected_to(conn) == "/login"
    end

    test "redirects to new with error when expired", %{
      conn: conn,
      user: user
    } do
      expiry_date = Timex.now() |> Timex.shift(days: -1)
      {:ok, %ResetPasswordToken{token: token}} = Factory.create_reset_password_token(user.id, expiry_date)

      params = %{
        "user" => %{
          "password" => "abc123"
        }
      }

      conn = put(conn, "reset-password/#{token}", params)

      assert html_response(conn, 200) =~ "Reset password link has expired."
      assert html_response(conn, 200) =~ "Reset password"
    end

    test "redirects to new with error when token already used", %{
      conn: conn,
      user: user
    } do
      expiry_date = Timex.now() |> Timex.shift(days: 1)
      {:ok, %ResetPasswordToken{token: token}} = Factory.create_reset_password_token(user.id, expiry_date, true)

      params = %{
        "user" => %{
          "password" => "abc123"
        }
      }

      conn = put(conn, "reset-password/#{token}", params)

      assert html_response(conn, 200) =~ "Reset password link has already been used."
      assert html_response(conn, 200) =~ "Reset password"
    end

    test "redirects to new with error when token doesn't exist", %{
      conn: conn
    } do
      params = %{
        "user" => %{
          "password" => "abc123"
        }
      }

      conn = put(conn, "reset-password/123", params)
      assert html_response(conn, 200) =~ "Reset password link is invalid."
      assert html_response(conn, 200) =~ "Reset password"
    end
  end
end
