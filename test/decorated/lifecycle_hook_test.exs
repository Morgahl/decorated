defmodule Decorated.LifecycleHookTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Decorated.Mocks.ExceptionGenServer
  alias Decorated.Mocks.ExitingGenServer
  alias Decorated.Mocks.HealthyGenServer
  alias Decorated.Mocks.ThrowingGenServer

  describe "HealthyGenServer" do
    test "forwards state through every callback and runs the start and stop hooks" do
      initial_state = %{count: 0}
      from = {self(), make_ref()}
      reason = :normal

      {_, log} =
        with_log(fn ->
          assert {:ok, state, {:continue, continue}} = HealthyGenServer.init(initial_state)
          assert {:noreply, state} = HealthyGenServer.handle_continue(continue, state)
          assert {:reply, ^from, state} = HealthyGenServer.handle_call(:call, from, state)
          assert {:noreply, state} = HealthyGenServer.handle_cast(:cast, state)
          assert {:noreply, state} = HealthyGenServer.handle_info(:info, state)
          assert {:ok, ^reason} = HealthyGenServer.terminate(reason, state)
        end)

      assert log =~ "Decorated.Mocks.HealthyGenServer.init_start(%{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.init_stop({:ok, %{count: 0}, {:continue, :continue}}, :ok, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_continue_start(:continue, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_continue_stop({:noreply, %{count: 0}}, :ok, :continue, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_call_start(:call, #{inspect(from)}, %{count: 0})"

      assert log =~
               "Decorated.Mocks.HealthyGenServer.handle_call_stop({:reply, #{inspect(from)}, %{count: 0}}, :ok, :call, #{inspect(from)}, %{count: 0})"

      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_cast_start(:cast, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_cast_stop({:noreply, %{count: 0}}, :ok, :cast, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_info_start(:info, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.handle_info_stop({:noreply, %{count: 0}}, :ok, :info, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.terminate_start(:normal, %{count: 0})"
      assert log =~ "Decorated.Mocks.HealthyGenServer.terminate_stop({:ok, :normal}, :ok, :normal, %{count: 0})"
    end
  end

  describe "ThrowingGenServer" do
    test "rethrows from every callback given the initial state and runs the exception hooks" do
      state = %{count: 0}
      from = {self(), make_ref()}
      reason = :normal

      {_, log} =
        with_log(fn ->
          assert {ThrowingGenServer, :init_failure} = catch_throw(ThrowingGenServer.init(state))
          assert {ThrowingGenServer, :continue_failure} = catch_throw(ThrowingGenServer.handle_continue(:continue, state))
          assert {ThrowingGenServer, :call_failure} = catch_throw(ThrowingGenServer.handle_call(:call, from, state))
          assert {ThrowingGenServer, :cast_failure} = catch_throw(ThrowingGenServer.handle_cast(:cast, state))
          assert {ThrowingGenServer, :info_failure} = catch_throw(ThrowingGenServer.handle_info(:info, state))
          assert {ThrowingGenServer, :terminate_failure} = catch_throw(ThrowingGenServer.terminate(reason, state))
        end)

      assert log =~ "Decorated.Mocks.ThrowingGenServer.init_start(%{count: 0})"
      assert log =~ "Decorated.Mocks.ThrowingGenServer.init_exception({:throw, {Decorated.Mocks.ThrowingGenServer, :init_failure}, ["
      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_continue_start(:continue, %{count: 0})"

      assert log =~
               "Decorated.Mocks.ThrowingGenServer.handle_continue_exception({:throw, {Decorated.Mocks.ThrowingGenServer, :continue_failure}, ["

      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_call_start(:call, #{inspect(from)}, %{count: 0})"
      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_call_exception({:throw, {Decorated.Mocks.ThrowingGenServer, :call_failure}, ["
      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_cast_start(:cast, %{count: 0})"
      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_cast_exception({:throw, {Decorated.Mocks.ThrowingGenServer, :cast_failure}, ["
      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_info_start(:info, %{count: 0})"
      assert log =~ "Decorated.Mocks.ThrowingGenServer.handle_info_exception({:throw, {Decorated.Mocks.ThrowingGenServer, :info_failure}, ["
      assert log =~ "Decorated.Mocks.ThrowingGenServer.terminate_start(:normal, %{count: 0})"

      assert log =~
               "Decorated.Mocks.ThrowingGenServer.terminate_exception({:throw, {Decorated.Mocks.ThrowingGenServer, :terminate_failure}, ["
    end
  end

  describe "ExceptionGenServer" do
    test "reraises from every callback given the initial state and runs the exception hooks" do
      state = %{count: 0}
      from = {self(), make_ref()}
      reason = :normal

      {_, log} =
        with_log(fn ->
          assert %RuntimeError{message: "init_failure"} = catch_error(ExceptionGenServer.init(state))
          assert %RuntimeError{message: "continue_failure"} = catch_error(ExceptionGenServer.handle_continue(:continue, state))
          assert %RuntimeError{message: "call_failure"} = catch_error(ExceptionGenServer.handle_call(:call, from, state))
          assert %RuntimeError{message: "cast_failure"} = catch_error(ExceptionGenServer.handle_cast(:cast, state))
          assert %RuntimeError{message: "info_failure"} = catch_error(ExceptionGenServer.handle_info(:info, state))
          assert %RuntimeError{message: "terminate_failure"} = catch_error(ExceptionGenServer.terminate(reason, state))
        end)

      assert log =~ "Decorated.Mocks.ExceptionGenServer.init_start(%{count: 0})"
      assert log =~ ~s|Decorated.Mocks.ExceptionGenServer.init_exception({:error, %RuntimeError{message: "init_failure"}, [|
      assert log =~ "Decorated.Mocks.ExceptionGenServer.handle_continue_start(:continue, %{count: 0})"
      assert log =~ ~s|Decorated.Mocks.ExceptionGenServer.handle_continue_exception({:error, %RuntimeError{message: "continue_failure"}, [|
      assert log =~ "Decorated.Mocks.ExceptionGenServer.handle_call_start(:call, #{inspect(from)}, %{count: 0})"
      assert log =~ ~s|Decorated.Mocks.ExceptionGenServer.handle_call_exception({:error, %RuntimeError{message: "call_failure"}, [|
      assert log =~ "Decorated.Mocks.ExceptionGenServer.handle_cast_start(:cast, %{count: 0})"
      assert log =~ ~s|Decorated.Mocks.ExceptionGenServer.handle_cast_exception({:error, %RuntimeError{message: "cast_failure"}, [|
      assert log =~ "Decorated.Mocks.ExceptionGenServer.handle_info_start(:info, %{count: 0})"
      assert log =~ ~s|Decorated.Mocks.ExceptionGenServer.handle_info_exception({:error, %RuntimeError{message: "info_failure"}, [|
      assert log =~ "Decorated.Mocks.ExceptionGenServer.terminate_start(:normal, %{count: 0})"
      assert log =~ ~s|Decorated.Mocks.ExceptionGenServer.terminate_exception({:error, %RuntimeError{message: "terminate_failure"}, [|
    end
  end

  describe "ExitingGenServer" do
    test "re-exits from every callback given the initial state and runs the exception hooks" do
      state = %{count: 0}
      from = {self(), make_ref()}
      reason = :normal

      {_, log} =
        with_log(fn ->
          assert :init_failure = catch_exit(ExitingGenServer.init(state))
          assert :continue_failure = catch_exit(ExitingGenServer.handle_continue(:continue, state))
          assert :call_failure = catch_exit(ExitingGenServer.handle_call(:call, from, state))
          assert :cast_failure = catch_exit(ExitingGenServer.handle_cast(:cast, state))
          assert :info_failure = catch_exit(ExitingGenServer.handle_info(:info, state))
          assert :terminate_failure = catch_exit(ExitingGenServer.terminate(reason, state))
        end)

      assert log =~ "Decorated.Mocks.ExitingGenServer.init_start(%{count: 0})"
      assert log =~ "Decorated.Mocks.ExitingGenServer.init_exception({:exit, :init_failure, ["
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_continue_start(:continue, %{count: 0})"
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_continue_exception({:exit, :continue_failure, ["
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_call_start(:call, #{inspect(from)}, %{count: 0})"
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_call_exception({:exit, :call_failure, ["
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_cast_start(:cast, %{count: 0})"
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_cast_exception({:exit, :cast_failure, ["
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_info_start(:info, %{count: 0})"
      assert log =~ "Decorated.Mocks.ExitingGenServer.handle_info_exception({:exit, :info_failure, ["
      assert log =~ "Decorated.Mocks.ExitingGenServer.terminate_start(:normal, %{count: 0})"
      assert log =~ "Decorated.Mocks.ExitingGenServer.terminate_exception({:exit, :terminate_failure, ["
    end
  end
end
