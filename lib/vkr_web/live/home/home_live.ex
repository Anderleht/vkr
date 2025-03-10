defmodule VkrWeb.HomeLive do
  @moduledoc false
  use VkrWeb, :live_view

  import VkrWeb.Home.Partials.RequestBodyRender

  alias Vkr.Requests
  alias Vkr.Sessions

  require Logger

  @sid_regex ~r/([a-z]+-)([a-z]+-)\d{2}/

  embed_templates("partials/*")

  @impl true
  def mount(params, _session, socket) do
    case Map.get(params, "path_info") do
      [sid] ->
        {:ok, configure_session(socket, sid, nil)}

      [sid, rid] ->
        {:ok, configure_session(socket, sid, rid)}

      _ ->
        {:ok, redirect_to_new_session(socket)}
    end
  end

  @impl true
  def handle_params(%{"path_info" => path_info}, _session, socket) do
    {sid, path_info} = List.pop_at(path_info, 0)
    {rid, _} = List.pop_at(path_info, 0)

    requests = Requests.list_by_sid(sid)
    current = get_current_request(requests, rid)
    new_rid = Map.get(current || %{}, :id)
    request_count = length(requests)

    socket =
      socket
      |> stream(:requests, requests)
      |> assign(:request_count, request_count)
      |> assign(:sid, sid)
      |> assign(:rid, new_rid)
      |> assign(:current, current)
      |> assign(page_title: "[Vkr] #{sid}")
      |> then(&if(is_nil(rid) && new_rid, do: push_patch(&1, to: ~p"/#{sid}/#{new_rid}"), else: &1))

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => <<"requests-" <> id>>}, socket) do
    sid = socket.assigns[:sid]

    case Requests.delete_by_sid_and_id(sid, id) do
      {:ok, _} ->
        {:noreply, socket}

      error ->
        Logger.error("delete error #{inspect(error)}")
        {:noreply, put_flash(socket, :error, "error deleting #{id}")}
    end
  end

  @impl true
  def handle_event("delete_all", _, socket) do
    sid = socket.assigns[:sid]

    case Requests.delete_all_by_sid(sid) do
      {:ok, _deleted} -> {:noreply, socket}
      {:error, _} -> {:noreply, put_flash(socket, :error, "error deleting all requests")}
    end
  end

  @impl true
  def handle_info({:created, req}, socket) do
    current = socket.assigns[:current] || req

    socket =
      socket
      |> stream_insert(:requests, req, at: 0)
      |> assign(:current, current)
      |> update(:request_count, &(&1 + 1))
      |> put_flash(:info, "Ahoy! A new request was hooked!")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:deleted, id}, socket) do
    socket
    |> stream_delete_by_dom_id(:requests, "requests-#{id}")
    |> put_flash(:info, "Request #{id} deleted!")
    |> update(:request_count, &(&1 - 1))
    |> case do
      %{assigns: %{current: %{id: ^id}}} = socket -> assign(socket, :current, nil)
      socket -> socket
    end
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({:all_deleted, deleted}, socket) do
    sid = socket.assigns[:sid]

    socket =
      socket
      |> stream(:requests, [], reset: true)
      |> update(:request_count, &(&1 - deleted))
      |> assign(:current, nil)
      |> push_navigate(to: ~p"/#{sid}")
      |> then(&if deleted > 0, do: put_flash(&1, :info, "all requests deleted!"), else: &1)

    {:noreply, socket}
  end

  defp configure_session(socket, sid, rid) do
    if String.match?(sid, @sid_regex) do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(Vkr.PubSub, "requests:#{sid}")
      end

      target_url = %URI{socket.host_uri | host: "#{sid}.#{socket.host_uri.host}"}

      socket
      |> then(&if rid, do: assign(&1, :rid, rid), else: &1)
      |> assign(:sid, sid)
      |> assign(:target_url, URI.to_string(target_url))
      |> assign(:request_count, 0)
      |> stream_configure(:requests, dom_id: &"requests-#{&1.id}")
    else
      redirect_to_new_session(socket)
    end
  end

  defp get_current_request(requests, nil) do
    requests
    |> Kernel.||([])
    |> List.first()
  end

  defp get_current_request(requests, rid) do
    requests
    |> Kernel.||([])
    |> Enum.find(&(&1.id == rid))
  end

  defp redirect_to_new_session(socket) do
    sid = Sessions.generate_sid()
    redirect(socket, to: "/#{sid}")
  end
end
