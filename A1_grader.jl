### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 65d601a6-fe45-11ea-22c6-270bf7d353bc
begin
	
	import Pluto
	import UUIDs: UUID
	import Distributed
	using PlutoUI
	using DataFrames
	import CSV
	import BrowseTables
	import Statistics
	import Random
	import StableRNGs
	import JLD2
	import StatsPlots
end

# ╔═╡ e545b134-094a-47c7-8e39-f257176f8fa1
let
	# Add packages for assignment notebook.
	# import StatsPlots
end

# ╔═╡ 68da9dec-e6e1-11ea-1d9e-cdb7028f9b6a
md"# Part 1: autograding"

# ╔═╡ 836cc4be-e6d7-11ea-2a6e-436c187304da
md"## Step 1: Setup"

# ╔═╡ 4e4e78d2-f865-11ea-0c21-fdd76cbf3532
md"You need to write some code that returns the **absolute paths** to the students' homework submissions. The following code works for me, but probably not for you."

# ╔═╡ 427f19de-e6d2-11ea-10a8-5d3552224b31
submission_files = let
	all = readdir(joinpath(@__DIR__, "a1_submissions/"); join=true)
	filter(f -> endswith(f, ".jl"), all)
end

# ╔═╡ 6b40e1d0-f865-11ea-3c2a-39fb643c8068
md"It should return an arrays of strings, something like:"

# ╔═╡ 728d1ca8-f865-11ea-1a3e-33cb0a44b9dd
submission_files_EXAMPLE = ["/home/fonsi/hw1/submissions/hw1 - fonsi.jl", "/home/fonsi/hw1/submissions/hw1 - template.jl"]

# ╔═╡ 8046609b-7ca7-41f3-a025-a3151069ebe5
begin
	autograde_save_loc = "a1_autograde_results"
	manual_save_loc = "a1_manual_results"
	final_save_loc = "a1_final_results"
end

# ╔═╡ 54a34bca-d981-40a4-b07c-1daead6bbfbd
md"""
Next you need to select a filename for the grades to be saved to. These will default to saving in the location the grader notebook is located, but can be made absolute to override this behaviour. Currently these will save to:
- **Autograde**: $(joinpath(@__DIR__, autograde_save_loc)*"{.jld2, .csv}")
- **Manual**: $(joinpath(@__DIR__, manual_save_loc)*"{.jld2, .csv}")
- **Final**: $(joinpath(@__DIR__, final_save_loc)*"{.jld2, .csv}")
"""

# ╔═╡ 54c9b77c-e6e2-11ea-03ff-5d0d4a9dd763
if !all(isabspath, submission_files)
	md"""
!!! warning
    Submission paths need to be _absolute_
	"""
end

# ╔═╡ d0dd703a-e6da-11ea-1d4f-0b10bf75fad6
md"## Step 2: autograde actions"

# ╔═╡ a0776916-f865-11ea-387a-bf2e3094a182
md"I have already written these, you can ignore this."

# ╔═╡ 8c6c6114-e6d7-11ea-20b1-e718907e0767
md"## Step 3: autograde all notebooks"

# ╔═╡ b5d0d970-e6d9-11ea-20a5-01f0c4e3875c
begin
	pluto_session = Pluto.ServerSession(;options=Pluto.Configuration.from_flat_kwargs(
		launch_browser=false, 
		require_secret_for_open_links=false,
		require_secret_for_access=false,
		workspace_use_distributed=false,
		port=2468))
	submission_files_to_run = Pluto.tamepath.(submission_files)
	md"Defined: `pluto_session` and `submission_files_to_run`"
end

# ╔═╡ a1598cfc-e6d7-11ea-1f0b-f5560304fe7a
md"""**Click to start running the notebooks:**

 **Start grading notebooks?**: $(@bind run_notebooks CheckBox())
 $(@bind continue_ag Select(["Regrade", "Continue"]))

---"""

# ╔═╡ 3fb6b20c-e6e1-11ea-35eb-e74598e31daf
md"""# Part 2: manual review

This section is useful to answer questions, or to review visual parts of the notebook. There is currently no way to add manual grades to the 

"""

# ╔═╡ 9090ee3e-e6de-11ea-14c3-27032e8710d3
md"## Step 1: start notebook server"

# ╔═╡ 9c1c40f0-e6de-11ea-08d8-77acb2a550d4
md"**Click to start notebook server:**

 $(@bind run_server_check CheckBox()) run notebook server

---"

# ╔═╡ 68fed8f8-f36e-46cc-ae1e-1db0c381af3d
run_server = try
	run_server || run_server_check
catch
	run_server_check
end

# ╔═╡ a3e47050-e6de-11ea-2a91-0597143f71ba
if run_server
	@async Pluto.run(pluto_session)
	
	md"> Server is running at [https://localhost:2468](https://localhost:2468)"
else
	md"Server is not running"
end

# ╔═╡ e0157682-57ce-4980-aed3-7d60e59f02aa
@bind reset_sd_list Button("Reset Shutdown List")

# ╔═╡ 8904534a-e6e1-11ea-34b7-31d1f6f8ca8f
md"## Step 2: select notebook"

# ╔═╡ 9815b7f4-f686-11ea-0760-05b34811be7f
md"""
#### Autograde results for selected homework

$(@bind inspected_notebook_index_str Select([string(i) => basename(fn) for (i, fn) in enumerate(submission_files_to_run)]))
"""

# ╔═╡ 97de35f8-fdbb-4797-8ace-6b2afb31dea9
begin
	reset_sd_list
	inspected_notebook_index_str
	get_path_name(nb) = basename(getproperty(nb, :path))
	nbs = [string(k)=>get_path_name(nb) for (k, nb) in pluto_session.notebooks]
	md"""
	#### Shutdown Selected Notebooks
	
	If you shutdown currently viewed notebook you will see a propt to go to the main menu. Either selection should be fine, and you won't move away from this screen. The reset button is useful for getting the current list of running notebooks.
	
	$(@bind running_nbs_uuids_str MultiSelect(nbs))
	
	Click to shutdown: $(@bind shutdown_cb CheckBox())
	"""
end

# ╔═╡ b8d4598c-f686-11ea-24dc-6f94370fc996
md"#### Editable view of selected homework"

# ╔═╡ 72fe1000-e5f1-4e4c-9dd4-69750619ea3d
md"""# Part 3: Statistics

This section is useful to look at the statistics of the assignment.

"""

# ╔═╡ b67e03e6-de75-450b-b27b-9ace41065869
StatsPlots.plot();

# ╔═╡ 8d1aaee8-e6de-11ea-2c2c-4d2ba138d5ce
md"# Appendix"

# ╔═╡ ce055a44-e6d8-11ea-3a07-75392c0f6c26
md"## Grading actions"

# ╔═╡ c1f5bd3a-e6d2-11ea-20ab-d93e142aa71e
abstract type GradingAction end

# ╔═╡ 8b9a3f7a-e6d4-11ea-34c5-ef986e6af936
begin
	# default
	displayname(action::GradingAction) = action.name
	point_value(action::GradingAction) = 0
end

# ╔═╡ 9057dc04-e6d2-11ea-196b-1519cac7d248
struct AutoTestAction <: GradingAction
	name
	points_value::Number
	test::Expr
end

# ╔═╡ 4e5a48c6-c7a8-4bc1-a3aa-7f0aa2e0f1e9
point_value(action::AutoTestAction) = action.points_value

# ╔═╡ cf32b78e-d0ea-4483-8ce6-1ad2cb7e8389
begin
	struct AutoPartialTestAction{N<:Number} <: GradingAction
    	name::String
    	point_values::Vector{N}
    	tests::Vector{Expr}
	end
end

# ╔═╡ 7296cc0d-9aea-40bd-8a3e-851ab05d1dfb
point_value(action::AutoPartialTestAction) = sum(action.point_values)

# ╔═╡ 3abb56e4-e6d3-11ea-3337-392a434e1a21
struct GetValue <: GradingAction
	name
	getter::Expr
end

# ╔═╡ eaa49370-e6da-11ea-21d9-ddf11a7df51f
begin
actions = let
	Random.seed!(10292)
	x = rand(10)
	μ = Statistics.mean(x)
	σ² = Statistics.var(x, corrected=true)
	σ = sqrt(Statistics.var(x, corrected=true))
	
	σ̃² = Statistics.var(x, corrected=false)
	σ̃ = sqrt(Statistics.var(x, corrected=false))

	u = [1.0, 2.0, 3.0, 4.0, 5.0]
	
	μᵤ = Statistics.mean(u)
	σ²ᵤ = Statistics.var(u, corrected=true)
	σᵤ = sqrt(Statistics.var(u, corrected=true))
	
	σ̃²ᵤ = Statistics.var(u, corrected=false)
	σ̃ᵤ = sqrt(Statistics.var(u, corrected=false))

	actions = [
		GetValue("name", :(student.name)),
		GetValue("ccid", :(student.ccid)),
		GetValue("id", :(student.idnumber)),
		GetValue("file", :(basename(__3102_file_name))),
		AutoPartialTestAction("mean", [1, 3], [ 
				quote
					mean($(u)) ≈ $(μᵤ)
				end, 
				quote
					mean($(x)) ≈ $(μ)
				end]),
		AutoPartialTestAction("var", [1, 3, 1],
				[quote
					local v = var($(u))
					v ≈ $(σ²ᵤ) || v ≈ $(σ̃²ᵤ)
				end,
				quote
					local v = var($(x))
					v ≈ $(σ²) || v ≈ $(σ̃²)
				end,
				quote
					local v = var($(x))
					v ≈ $(σ²)
				end]),
		AutoPartialTestAction("stddev", [1, 3, 1],
				[quote
					local v = stddev($(u))
					v ≈ $(σᵤ) || v ≈ $(σ̃ᵤ)
				end,
				quote
					local v = stddev($(x))
					v ≈ $(σ) || v ≈ $(σ̃)
				end,
				quote
					local v = stddev($(x))
					v ≈ $(σ)
				end])
		]
end
	
num_value_actions = sum([a isa GetValue for a in actions])
md"### $(length(actions)) Auto Grading Actions Defined here"
	
end

# ╔═╡ c0d9fb36-f858-11ea-35c0-77963b5cf57a
begin
	autograde_total_points = sum(actions) do action
		try
			point_value(action)
		catch
			0
		end
	end
	"<h4> There are <span style=\"color:red\"> $(autograde_total_points) </span> autograded points. </h4>" |> HTML
end

# ╔═╡ 3729a10f-0819-49c3-ad31-13d55afe82b3
md"""#### Explore questions

$(@bind explore_action Select([string(idx)=>n for (idx, n) in enumerate(displayname.(actions))]))

"""

# ╔═╡ d9f7702e-9550-48aa-a420-8e27df10a161
let
	idx = tryparse(Int, explore_action)
	if actions[idx] isa AutoPartialTestAction
		actions[idx].tests
	elseif actions[idx] isa AutoTestAction
		actions[idx].test
	end
end

# ╔═╡ 96917e4e-f687-11ea-2256-7b1057a3b523
begin
	struct ManualScoreAction <: GradingAction
		name
		points_value::Number
		rubric
	end
	ManualScoreAction(name, points_value) = ManualScoreAction(name, points_valie, name)
end

# ╔═╡ e5d3fa7c-f687-11ea-044f-6b00f0321da8
begin
	struct ManualCheckAction <: GradingAction
		name
		points_value::Number
		rubric
	end
	ManualCheckAction(name, points_value) = ManualCheckAction(name, points_valie, name)
end

# ╔═╡ e48f2a16-e6e1-11ea-070a-d58f87569b91
md"## Running and Managing Notebooks"

# ╔═╡ 882283b4-ec69-4a7f-9886-a33687d49e62
function shutdown_notebook(session, nb)
	Pluto.SessionActions.shutdown(session, nb)
end

# ╔═╡ ba3953c4-987d-4953-87ff-9467ef48bc21
function shutdown_notebook(session, path::AbstractString)
	idx = findfirst(pluto_session.notebooks) do nb
		nb.path == path
	end
	shutdown_notebook(session, session.notebooks[idx])
end

# ╔═╡ 63e2fdf4-97b7-4d8b-9f73-6e26e8655f3e
if shutdown_cb
	for uuid_str in running_nbs_uuids_str
		uuid = UUID(uuid_str)
		if uuid ∈ keys(pluto_session.notebooks)
			shutdown_notebook(pluto_session, pluto_session.notebooks[uuid])
		end
	end
	md"Shutdown Successful, Hit Reset Shutdown List to refresh the list."
else
	md"Shutdown halted. Check `click to shutdown` to start."
end

# ╔═╡ c403dbb5-85aa-4bc1-a35c-76e685e297e9
function shutdown_notebooks(session, notebooks=session.notebooks)
	for nb in values(session.notebooks)
		Pluto.SessionActions.shutdown(session, nb)
    end
end

# ╔═╡ 590154e3-9b90-4d5a-9836-eaf4fc5d1a91
function results_to_df(ag_results, actions)
	df = DataFrame(map(ag_results) do results
		(;
			map(zip(actions, results)) do (action, result)
				Symbol(displayname(action)) => result
			end...
		)
	end)
	
	function get_total(row)
		# scores = Vector{Number}()
		total_score = 0
		for (a, c) in zip(actions, row)
			if point_value(a) != 0
				if c isa NamedTuple
					total_score += c.total
				elseif c isa Vector
					total_score += sum(c)
				else
					total_score += c
				end
			end
		end
		total_score
	end
	
	df[!, :total] = [get_total(row) for row in eachrow(df)]

	df
end

# ╔═╡ a62c874b-e534-40c3-905d-674083570954
results_to_df(ag_results::DataFrame, actions) = ag_results

# ╔═╡ 33588e20-e6d4-11ea-08f6-7d10d9ef1481
function eval_in_notebook(session, notebook::Pluto.Notebook, expr)
	ws = Pluto.WorkspaceManager.get_workspace((session, notebook))
	fetcher = :(Core.eval($(ws.module_name), $(expr |> QuoteNode)))
	Distributed.remotecall_eval(Main, ws.pid, fetcher)
end

# ╔═╡ 31111cbe-e6d3-11ea-0130-a98e45b82f2b
begin
	function do_action(session, notebook::Pluto.Notebook, action::AutoTestAction)
		tester = quote
				try
					$(action.test)
				catch
					false
				end
			end
		
		if eval_in_notebook(session, notebook, tester) === true
			action.points_value
		else
			zero(action.points_value)
		end
	end
	
	function do_action(session, notebook::Pluto.Notebook, action::AutoPartialTestAction)

		res = fill(false, length(action.tests))
		for (idx, test) in enumerate(action.tests)
			tester = quote
				try
					$(test)
				catch
					false
				end
			end
			res[idx] = eval_in_notebook(session, notebook, tester)
		end

		# (total=sum(action.point_values[res]), split=res)
		action.point_values .* res
	end
	
	function do_action(session, notebook::Pluto.Notebook, action::GetValue)
		eval_in_notebook(session, notebook, action.getter)
	end
end

# ╔═╡ 9047ede9-a021-4ff6-bf39-19ae2052b99d
function autograde_notebooks(session, notebooks, actions)
	
		
	autograde_results = map(notebooks) do nb
		map(actions) do action
			do_action(session, nb, action)
		end
	end
	autograde_results
	# results_to_df(ag_results, actions)
end

# ╔═╡ b8c7c136-eb0b-453b-be6a-52daef51bc05
function start_notebook(session, path)
	nb = Pluto.load_notebook(Pluto.tamepath(path))
	session.notebooks[nb.notebook_id] = nb
	Pluto.update_save_run!(session, nb, nb.cells; run_async=false, prerender_text=true)
	eval_in_notebook(session, nb, 
		quote
			__3102_file_name = $(basename(path))
		end
		)
	nb
end

# ╔═╡ 6c4f0381-dd9a-459b-aed7-f6a130756e81
function start_notebooks(session, paths)
	shutdown_notebooks(session)
	map(submission_files_to_run) do path
		nb = start_notebook(session, path)
		nb
	end
end

# ╔═╡ 5642a754-e6d9-11ea-35b6-0fe20d6a098e
# Checkbox value, will run when run if checked
# somewhere there is a cd, and I can't find it. We should make sure the working directory remains consistent:

autograde_results_df, _notebooks = let

	if run_notebooks && continue_ag == "Regrade"
		
		cur_pwd = pwd()
		notebooks = start_notebooks(pluto_session, submission_files_to_run)
		res = autograde_notebooks(pluto_session, notebooks, actions)
		cd(cur_pwd)
		results_to_df(res, actions), notebooks

	elseif run_notebooks && 
		   continue_ag == "Continue" && 
		   isfile(joinpath(@__DIR__, autograde_save_loc)*".jld2")
		
		error("Not Implemented Yet")
		
	elseif !run_notebooks && isfile(joinpath(@__DIR__, autograde_save_loc)*".jld2")
		# "Yes Queen"
		df = JLD2.load(joinpath(@__DIR__, autograde_save_loc)*".jld2", "grades")
		df, []
	else
		nothing, []
	end
end;

# ╔═╡ 7cb1c9bc-f684-11ea-00f3-dfd11c9b72ef
if autograde_results_df isa DataFrame
	BrowseTables.HTMLTable(autograde_results_df)
end

# ╔═╡ 3f0aec92-e6e1-11ea-1b53-29b7b543674d
autograde_results_df

# ╔═╡ c9a66a4a-e6e4-11ea-0528-f3bbf6f17675
md"""
Below you can choose to save or download the graded results. If you save the results, this can be used later by the notebook and will prevent the notebooks from being re-run. This will override the current set of grades at $(joinpath(@__DIR__, autograde_save_loc)).

 **Save Autogrades**: $(@bind save_autograde CheckBox())

 **Export Autogrades**: $(@bind export_autograde CheckBox()) $(@bind export_option Select(["total-only", "full-details", "custom"])) compress vectors?: $(@bind export_compress CheckBox(default=true))

$(@bind export_params MultiCheckBox(names(autograde_results_df)))
"""

# ╔═╡ fdab51ed-5fc5-467f-83b6-9a6cd3cfac5f
let
	if save_autograde
		# Use JLD2 to save the dataframe.
		JLD2.save(joinpath(@__DIR__, autograde_save_loc)*".jld2", 
				  "grades", autograde_results_df)
	end
	path = joinpath(@__DIR__, autograde_save_loc)*".jld2"
	
	md"Save successful to $(path)"
end

# ╔═╡ f60a0a91-947b-4d3d-93da-d81cd428cdee
let
	if export_autograde

		export_idx = if export_option == "total-only"
			[names(autograde_results_df)[1:num_value_actions]; "total"]
		elseif export_option == "full-details"
			names(autograde_results_df)
		elseif export_option == "custom"
			export_params
		end

		df = autograde_results_df[:, export_idx]
		if export_compress
			for c_n in names(df)
				if eltype(df[!, c_n]) <: Vector
					df[!, c_n] = sum.(df[!, c_n])
				end
			end
		end
		CSV.write(joinpath(@__DIR__, autograde_save_loc)*".csv",
				  df)

	end
	path = joinpath(@__DIR__, autograde_save_loc)*".csv"
	
	md"Export successful to $(path)"
end

# ╔═╡ 64c26a50-e6df-11ea-2762-57186f445501
begin
	inspected_notebook_index = parse(Int, inspected_notebook_index_str)
	inspected_notebook = if run_server
		if run_notebooks
			_notebooks[inspected_notebook_index]
		else
			# search for notebook in notebooks. If doesn't exist then load and return.
			path = submission_files_to_run[inspected_notebook_index]
			idx = findfirst(pluto_session.notebooks) do nb
				nb.path == path
			end
			if isnothing(idx)
				start_notebook(pluto_session, path)
			else 
				pluto_session.notebooks[idx]
			end
		end
	end
	if run_server
		md"The notebook $(basename(inspected_notebook.path)) is running."
	else
		md"Server not running, no active notebook"
	end
end

# ╔═╡ 991ddb18-e6e6-11ea-220d-71b6794f39d8
autograde_results_df[inspected_notebook_index, :]

# ╔═╡ 508421de-d56f-412d-80c2-63388eb66a38
let
	idx = tryparse(Int, explore_action)
	points = do_action(pluto_session, inspected_notebook, actions[idx])
	points_str = string(points)	
	nme = autograde_results_df[inspected_notebook_index, "name"]
	md"""
	$(nme) got $(points_str) on this question.
	"""
end

# ╔═╡ 3b4973a0-e9cb-4b77-9e78-65c7e0efe4a7
eval_in_notebook(pluto_session, inspected_notebook, quote
		# Test code here
		mean([1.0, 2.0, 3.0, 4.0, 5.0]) 
end)

# ╔═╡ b6b986c8-e6de-11ea-1d13-5d9d370eccdc
if run_server
	cd(inspected_notebook.path |> dirname) do
		"""
		<iframe src="http://localhost:2468/edit?id=$(inspected_notebook.notebook_id)" style="width: calc(100% - 8px); height: 100vh; margin: 0; border: 4px solid pink;"  allow="camera;microphone">
		""" |> HTML
	end
end

# ╔═╡ c8f282c4-a66d-4632-b2a7-e5854772f9fe
@bind question_details MultiCheckBox(names(autograde_results_df)[num_value_actions+1:end])

# ╔═╡ be9e8cd3-5171-47ab-9ab1-446974f34dbf
let
if !isnothing(question_details) 
	df = autograde_results_df
	plt = StatsPlots.plot()
	for qd in question_details
		squash = if eltype(df[!, qd]) <: Vector
			sum
		else
			identity
		end
		X = squash(df[!, qd])
		StatsPlots.violin!([qd], X, grid=false, tickdir=:out, lw=0, color=StatsPlots.RGB(87/255, 123/255, 181/255), legend=nothing)
		StatsPlots.boxplot!([qd], X, fillalpha=0.5, lw=3)
	end
	plt
end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BrowseTables = "5f4fecfd-7eb0-5078-b7f6-ad1f2563c22a"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StableRNGs = "860ef19b-820b-49d6-a774-d7a799459cd3"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
BrowseTables = "~0.3.0"
CSV = "~0.8.5"
DataFrames = "~1.2.2"
JLD2 = "~0.4.13"
Pluto = "~0.15.1"
PlutoUI = "~0.7.9"
StableRNGs = "~1.0.0"
StatsPlots = "~0.14.26"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgCheck]]
git-tree-sha1 = "dedbbb2ddb876f899585c4ec4433265e3017215a"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.1.0"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[Arpack_jll]]
deps = ["Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "e214a9b9bd1b4e1b4f15b22c0994862b66af7ff7"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.0+3"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BrowseTables]]
deps = ["ArgCheck", "DefaultApplication", "DocStringExtensions", "Parameters", "Tables"]
git-tree-sha1 = "2df4c05941860fd6149c349422d584174044718a"
uuid = "5f4fecfd-7eb0-5078-b7f6-ad1f2563c22a"
version = "0.3.0"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f53ca8d41e4753c41cdafa6ec5f7ce914b34be54"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.13"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random", "StaticArrays"]
git-tree-sha1 = "ed268efe58512df8c7e224d2e170afd76dd6a417"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.13.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Configurations]]
deps = ["Crayons", "ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "b8486a417456d2fbbe2af13e24cef459c9f42429"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.15.4"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "fc2b7122761b22c87fec8bf2ea4dc4563d9f8c24"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.0.0"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "abe4ad222b26af3337262b8afb28fab8d215e9f8"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3889f646423ce91dd1055a76317e9a1d3a23fff1"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.11"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExproniconLite]]
git-tree-sha1 = "c97ce5069033ac15093dc44222e3ecb0d3af8966"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.6.9"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8c8eac2af06ce35973c3eadb4ab3243076a408e7"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "b62fa7b1fe8716459846db4efbe786283d318a46"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.4.2"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "182da592436e287758ded5be6e32c406de3a2e47"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.58.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d59e8320c2747553788e4fc42231489cc602fa50"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.58.1+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "44e3b40da000eab4ccb1aecdc4801c040026aeb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.13"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "1470c80592cf1f0a35566ee5e93c5f8221ebc33a"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.3"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "59ee430ac5dc87bc3eec833cc2a37853425750b4"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.13"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "12ee7e23fa4d18361e7c2cde8f8337d4c3101bc7"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.10.0+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "5cc97a6f806ba1b36bac7078b866d4297ae8c463"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.4"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "e39bea10478c6aff5495ab522517fae5134b40e3"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.20.0"

[[Pluto]]
deps = ["Base64", "Configurations", "Dates", "Distributed", "FileWatching", "FuzzyCompletions", "HTTP", "InteractiveUtils", "Logging", "Markdown", "MsgPack", "Pkg", "REPL", "Sockets", "TableIOInterface", "Tables", "UUIDs"]
git-tree-sha1 = "6af6088f72ae82c8b6712047b5fe79c22016b878"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.15.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
git-tree-sha1 = "37d210f612d70f3f7d57d488cb3b6eff56ad4e41"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.0"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "2a7a2469ed5d94a98dea0e85c46fa653d76be0cd"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.3.4"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "a3a337914a035b2d59c9cbe7f1a38aaba1265b02"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.6"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "508822dca004bf62e210609148511ad03ce8f1d8"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.0"

[[StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3fedeffc02e47d6e3eb479150c8e5cd8f15a77a0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.10"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

[[StatsFuns]]
deps = ["LogExpFunctions", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "30cd8c360c54081f806b1ee14d2eecbef3c04c49"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.8"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "e7d1e79232310bd654c7cef46465c537562af4fe"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.26"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "000e168f5cc9aded17b6999a560b7c11dda69095"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.0"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableIOInterface]]
git-tree-sha1 = "9a0d3ab8afd14f33a35af7391491ff3104401a35"
uuid = "d1efa939-5518-4425-949f-ab857e148477"
version = "0.1.6"

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "a7cf690d0ac3f5b53dd09b5d613540b230233647"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.0.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "7c53c35547de1c5b9d46a4797cf6d8253807108c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.5"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "eae2fbbc34a79ffd57fb4c972b08ce50b8f6a00d"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.3"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╠═65d601a6-fe45-11ea-22c6-270bf7d353bc
# ╠═e545b134-094a-47c7-8e39-f257176f8fa1
# ╟─68da9dec-e6e1-11ea-1d9e-cdb7028f9b6a
# ╟─836cc4be-e6d7-11ea-2a6e-436c187304da
# ╟─4e4e78d2-f865-11ea-0c21-fdd76cbf3532
# ╟─427f19de-e6d2-11ea-10a8-5d3552224b31
# ╟─6b40e1d0-f865-11ea-3c2a-39fb643c8068
# ╟─728d1ca8-f865-11ea-1a3e-33cb0a44b9dd
# ╟─54a34bca-d981-40a4-b07c-1daead6bbfbd
# ╠═8046609b-7ca7-41f3-a025-a3151069ebe5
# ╟─54c9b77c-e6e2-11ea-03ff-5d0d4a9dd763
# ╟─d0dd703a-e6da-11ea-1d4f-0b10bf75fad6
# ╟─a0776916-f865-11ea-387a-bf2e3094a182
# ╟─eaa49370-e6da-11ea-21d9-ddf11a7df51f
# ╟─c0d9fb36-f858-11ea-35c0-77963b5cf57a
# ╠═7cb1c9bc-f684-11ea-00f3-dfd11c9b72ef
# ╟─8c6c6114-e6d7-11ea-20b1-e718907e0767
# ╟─b5d0d970-e6d9-11ea-20a5-01f0c4e3875c
# ╟─a1598cfc-e6d7-11ea-1f0b-f5560304fe7a
# ╟─5642a754-e6d9-11ea-35b6-0fe20d6a098e
# ╠═3f0aec92-e6e1-11ea-1b53-29b7b543674d
# ╟─c9a66a4a-e6e4-11ea-0528-f3bbf6f17675
# ╠═fdab51ed-5fc5-467f-83b6-9a6cd3cfac5f
# ╠═f60a0a91-947b-4d3d-93da-d81cd428cdee
# ╠═3fb6b20c-e6e1-11ea-35eb-e74598e31daf
# ╟─9090ee3e-e6de-11ea-14c3-27032e8710d3
# ╟─9c1c40f0-e6de-11ea-08d8-77acb2a550d4
# ╟─68fed8f8-f36e-46cc-ae1e-1db0c381af3d
# ╟─a3e47050-e6de-11ea-2a91-0597143f71ba
# ╟─97de35f8-fdbb-4797-8ace-6b2afb31dea9
# ╠═e0157682-57ce-4980-aed3-7d60e59f02aa
# ╟─63e2fdf4-97b7-4d8b-9f73-6e26e8655f3e
# ╟─8904534a-e6e1-11ea-34b7-31d1f6f8ca8f
# ╟─9815b7f4-f686-11ea-0760-05b34811be7f
# ╠═991ddb18-e6e6-11ea-220d-71b6794f39d8
# ╟─3729a10f-0819-49c3-ad31-13d55afe82b3
# ╟─508421de-d56f-412d-80c2-63388eb66a38
# ╠═d9f7702e-9550-48aa-a420-8e27df10a161
# ╠═3b4973a0-e9cb-4b77-9e78-65c7e0efe4a7
# ╟─b8d4598c-f686-11ea-24dc-6f94370fc996
# ╟─b6b986c8-e6de-11ea-1d13-5d9d370eccdc
# ╟─64c26a50-e6df-11ea-2762-57186f445501
# ╟─72fe1000-e5f1-4e4c-9dd4-69750619ea3d
# ╟─b67e03e6-de75-450b-b27b-9ace41065869
# ╠═c8f282c4-a66d-4632-b2a7-e5854772f9fe
# ╠═be9e8cd3-5171-47ab-9ab1-446974f34dbf
# ╟─8d1aaee8-e6de-11ea-2c2c-4d2ba138d5ce
# ╟─ce055a44-e6d8-11ea-3a07-75392c0f6c26
# ╟─c1f5bd3a-e6d2-11ea-20ab-d93e142aa71e
# ╟─8b9a3f7a-e6d4-11ea-34c5-ef986e6af936
# ╟─9057dc04-e6d2-11ea-196b-1519cac7d248
# ╟─4e5a48c6-c7a8-4bc1-a3aa-7f0aa2e0f1e9
# ╟─cf32b78e-d0ea-4483-8ce6-1ad2cb7e8389
# ╟─7296cc0d-9aea-40bd-8a3e-851ab05d1dfb
# ╟─3abb56e4-e6d3-11ea-3337-392a434e1a21
# ╟─31111cbe-e6d3-11ea-0130-a98e45b82f2b
# ╟─96917e4e-f687-11ea-2256-7b1057a3b523
# ╟─e5d3fa7c-f687-11ea-044f-6b00f0321da8
# ╟─e48f2a16-e6e1-11ea-070a-d58f87569b91
# ╟─b8c7c136-eb0b-453b-be6a-52daef51bc05
# ╟─6c4f0381-dd9a-459b-aed7-f6a130756e81
# ╟─882283b4-ec69-4a7f-9886-a33687d49e62
# ╟─ba3953c4-987d-4953-87ff-9467ef48bc21
# ╟─c403dbb5-85aa-4bc1-a35c-76e685e297e9
# ╠═9047ede9-a021-4ff6-bf39-19ae2052b99d
# ╟─590154e3-9b90-4d5a-9836-eaf4fc5d1a91
# ╟─a62c874b-e534-40c3-905d-674083570954
# ╠═33588e20-e6d4-11ea-08f6-7d10d9ef1481
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
