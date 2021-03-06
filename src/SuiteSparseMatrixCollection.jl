module SuiteSparseMatrixCollection

using Pkg.Artifacts

using DataFrames
using JLD2

export fetch_ssmc, ssmc_matrices, ssmc, ssmc_formats

const ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")

"Main database."
global ssmc

function __init__()
  file = jldopen(ssmc_jld2, "r")
  global ssmc = file["df"]
  last_rev_date = file["last_rev_date"]
  close(file)
  @info "loaded database with revision date" last_rev_date
end

"Formats in which matrices are available."
const ssmc_formats = ("MM", "RB")

"""
     fetch_ssmc(group::AbstractString, name::AbstractString; format="MM")

Download the matrix with name `name` in group `group`.
Return the path where the matrix is stored.
"""
function fetch_ssmc(group::AbstractString, name::AbstractString; format="MM")
  group_and_name = group * "/" * name * "." * format
  # download lazy artifact if not already done and obtain path
  loc = ensure_artifact_installed(group_and_name,
                                  joinpath(@__DIR__, "..", "Artifacts.toml"))
  return joinpath(loc, name)
end

"""
     fetch_ssmc(matrices; format="MM")

Download matrices from the SuiteSparseMatrixCollection.
The argument `matrices` should be a `DataFrame` or `DataFrameRow`.
An array of strings is returned with the paths where the matrices are stored.
"""
function fetch_ssmc(matrices; format="MM")
  format ∈ ssmc_formats || error("unknown format $format")
  paths = String[]
  for (group, name) ∈ zip(matrices.group, matrices.name)
    push!(paths, fetch_ssmc(group, name, format=format))
  end
  return paths
end

"""
    ssmc_matrices(group, name)

Return a `DataFrame` of matrices whose group contains the string `group` and whose
name contains the string `name`.

    ssmc_matrices(name)
    ssmc_matrices("", name)

Return a `DataFrame` of matrices whose name contains the string `name`.

    ssmc_matrices(group, "")

Return a `DataFrame` of matrices whose group contains the string `group`.

Example: `ssmc_matrices("HB", "bcsstk")`.
"""
function ssmc_matrices(group::AbstractString, name::AbstractString)
  ssmc[occursin.(group, ssmc.group) .& occursin.(name, ssmc.name), :]
end

ssmc_matrices(name::AbstractString) = ssmc_matrices("", name)

end
