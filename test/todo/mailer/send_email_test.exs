defmodule Todo.Mailer.SendEmailTest do
  use Todo.DataCase
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    Application.put_env(:todo, :send_grid_url, "http://localhost:#{bypass.port}")

    {:ok, bypass: bypass}
  end

  describe "perform/4" do
    test "with valid response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        {:ok, body_json, _map_data} = Plug.Conn.read_body(conn)
        params = Jason.decode!(body_json)

        assert params["content"] == [
                 %{"type" => "text/html", "value" => "This is the email content"}
               ]

        assert params["from"] == %{"email" => "hello@nicfisher.me", "name" => "Nic Fisher"}

        assert params["personalizations"] == [
                 %{
                   "subject" => "Email Subject",
                   "to" => [%{"email" => "john@email.com.au.au", "name" => "John"}]
                 }
               ]

        assert params["reply_to"] == %{"email" => "hello@nicfisher.me", "name" => "Nic Fisher"}

        Plug.Conn.resp(conn, 200, "")
      end)

      assert {:ok, "Request sent to SendGrid"} ==
               Todo.Mailer.SendEmail.perform(
                 "john@email.com.au.au",
                 "John",
                 "Email Subject",
                 "This is the email content"
               )
    end

    test "with invalid response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, Jason.encode!(invalid_response()))
      end)

      assert {:error, "The provided authorization grant is invalid, expired, or revoked"} ==
               Todo.Mailer.SendEmail.perform(
                 "john@email.com.au.au",
                 "John",
                 "Email Subject",
                 "This is the email content"
               )
    end
  end

  defp invalid_response() do
    %{
      errors: [
        %{
          message: "The provided authorization grant is invalid, expired, or revoked",
          field: nil,
          help: nil
        }
      ]
    }
  end
end
