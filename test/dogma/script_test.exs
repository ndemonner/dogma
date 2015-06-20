defmodule Dogma.ScriptTest do
  use ShouldI

  alias Dogma.Script
  alias Dogma.Error

  with "Script.parse" do

    with "a valid script" do
      setup context do
        source = ~s"""
        defmodule Foo do
          def greet do
            "Hello world!"
          end
        end
        """
        %{
          source: source,
          script: Script.parse( source, "lib/foo.ex" ),
        }
      end

      should "register path", context do
        assert "lib/foo.ex" == context.script.path
      end

      should "register source", context do
        assert context.source == context.script.source
      end

      should "assign an empty list of errors", context do
        assert [] == context.script.errors
      end

      should "assigns lines", context do
        lines = [
          {1,  "defmodule Foo do"},
          {2,  "  def greet do"},
          {3,  "    \"Hello world!\""},
          {4,  "  end"},
          {5,  "end"},
        ]
        assert lines == context.script.lines
      end

      should "assign valid? as true", context do
        assert true == context.script.valid?
      end

      should "assigns the quotes abstract syntax tree", context do
        {:ok, ast} = Code.string_to_quoted( context.source )
        assert ast == context.script.ast
      end

      should "include line numbers in the quoted ast" do
        script = Script.parse( "1 + 1", "" )
        assert {:+, [line: 1], [1, 1]} == script.ast
      end
    end


    with "an invalid script" do
      setup context do
        source = ~s"""
        <>>>>>>><><>><><>>>>>>>>>>>>>><<><
        """
        %{
          script: Script.parse( source, "" ),
        }
      end

      should "assign valid? as false", context do
        assert false == context.script.valid?
      end

      should "assign parse error in place of ast", context do
        error = {
          :error,
          {2, "missing terminator: >> (for \"<<\" starting at line 1)", ""}
        }
        assert error == context.script.ast
      end
    end
  end


  with ".add_error" do
    should "add the error. gosh." do
      error  = %Error{ rule: MustBeGood, message: "Not good!", position: 5 }
      script = %Script{} |> Script.register_error( error )
      assert [error] == script.errors
    end
  end
end
