#!/usr/bin/env  julia
using JuMP
using Gurobi

# Conjunto de aviões
A = ["A1", "A2", "A3"]

# Custos
C = Dict(
    "A1" => 5.1,
    "A2" => 3.6,
    "A3" => 6.8
)

#Receita Teórica
R = Dict(
    "A1" => 330,
    "A2" => 300,
    "A3" => 420
)

#pilotos aptos
P = Dict(
    "A1" => 30,
    "A2" => 20,
    "A3" => 10
)

M = Dict(
    "A1" => 1,
    "A2" => 0.75,
    "A3" => 1.66666666666667
)

capacidadeMax = 40
verba = 220


m = Model(with_optimizer(Gurobi.Optimizer))

@variable(m, x[A] >= 0)

# Implementação da função objetivo
@objective(m, Max, sum(x[i]*(R[i] - C[i]) for i in A))

@constraints(m, 
    begin
        sum(x[i]*M[i] for i in A) <= capacidadeMax
        sum(x[i]*C[i] for i in A) <= verba
        x["A3"]*2 <= P["A3"]
        x["A1"]*2 + x["A3"]*2 <= P["A1"] + P["A3"]
        x["A2"]*2 + x["A3"]*2 <= P["A2"] + P["A3"]
        sum(x[i]*2 for i in A) <= sum(P[i] for i in A)
    end)

println(m)

start = time()
optimize!(m)
println("Tempo: $(time()-start)s")

println("Valor ótimo: $(map(i-> JuMP.value(x[i]),A))")
println("Função ótima: ", JuMP.objective_value(m))
