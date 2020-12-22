defmodule Todo.Mailer.SendEmail do
  alias Todo.Config

  def perform(_to_email, to_name, subject, content) do
    case HTTPoison.post(
           Config.send_grid_url(),
           request_body(to_name, subject, content),
           headers()
         ) do
      {:ok, %HTTPoison.Response{body: ""}} -> {:ok, "Request sent to SendGrid"}
      {:ok, %HTTPoison.Response{body: body}} -> Jason.decode!(body) |> handle_error()
      _ -> {:error, "Error sending request to SendGrid"}
    end
  end

  defp request_body(to_name, subject, content) do
    content = %{
      personalizations: [
        %{
          to: [
            %{
              email: "nicfisher90@gmail.com",
              name: to_name
            }
          ],
          subject: subject
        }
      ],
      content: [
        %{type: "text/html", value: content}
      ],
      from: %{email: "hello@nicfisher.me", name: "Nic Fisher"},
      reply_to: %{email: "hello@nicfisher.me", name: "Nic Fisher"}
    }

    Jason.encode!(content)
  end

  defp headers() do
    [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Config.send_grid_api_key()}"}
    ]
  end

  defp handle_error(%{"errors" => [%{"message" => error}]}) do
    {:error, error}
  end

  defp handle_error(body), do: {:error, body}
end
