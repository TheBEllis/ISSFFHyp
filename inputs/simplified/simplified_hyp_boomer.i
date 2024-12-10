penalty = 1e6
pih_size = 124
pis_size = 124

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [meshy]
    type = FileMeshGenerator
    file = '../../mesh/simplified/simplified_hyp.e'
#    skip_partitioning = True
  []
[] 
  
[Variables]
  [temperature]
    family = LAGRANGE
  []
[]
  
[Kernels]
  # Heat conduction kernels
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
    block = '1'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    use_automatic_differentiation = true
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    #incremental = false
    #generate_output = 'vonmises_stress'
    eigenstrain_names = eigenstrain
  []
[]
  
# Functions to control variable material parameters
[Functions]
  
  [./pressure_constant]
    type = ConstantFunction
    value = 0.7e6 # 0.7 MPa
  [../]
  
  [./cucrzr_rho_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/density.csv'
    format = columns
  [../]

  # Copper Youngs modulus
  [./cucrzr_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/youngs_modulus.csv'
    format = columns
  [../]
  
  #Copper Thermal conductivity
  [./cucrzr_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/thermal_conductivity.csv'
    format = columns
  [../]

  #Copper Thermal expansion
  [./cucrzr_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/thermal_expansion.csv'
    format = columns
  [../]

  # Copper specific heat
  [./cucrzr_sh_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/specific_heat.csv'
    format = columns
  [../]

  #Nickel youngs modulus
  [./nickel_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/youngs_modulus.csv'
    format = columns
  [../]
  
  #Nickel thermal conductivity
  [./nickel_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/thermal_conductivity.csv'
    format = columns
  [../]

  #Nickel thermal expansion
  [nickel_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/thermal_expansion.csv'
    format = columns
  []
[]

  
[Materials]
  [CCZ_elasticity]
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus= 'ccz_ym'
    poissons_ratio = 0.33
    block = 1
  []

  [CCZ_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat_temperature_function = cucrzr_sh_fn
    thermal_conductivity_temperature_function = cucrzr_tc_fn
    block = 1
  []

  [CCZ_ym]
    type = ADPiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'ccz_ym'
    x = '2.000E+01 1.000E+02 1.500E+02 2.000E+02 2.500E+02 3.000E+02 3.500E+02 4.000E+02 4.500E+02 5.000E+02 6.000E+02 7.000E+02'
    y = '1.275E+11 1.270E+11 1.250E+11 1.230E+11 1.210E+11 1.180E+11 1.160E+11 1.130E+11 1.100E+11 1.060E+11 9.500E+10 8.600E+10'
    block = 1
  []

  [CCZ_density]
    type = ADPiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'density'
    x = '0 50 100 150 200 250 300 350 400 450 500'
    y = '8900 8886 8863 8840 8816 8791 8767 8742 8716 8691 8665'
    block = 1
  []

  [CCZ_thermal_expansion]
    type = ADComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cucrzr_te_fn
    thermal_expansion_function_reference_temperature = 0.5
    stress_free_temperature = 0.0
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = 1
  []

  [rbe_elasticity]
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus= 1
    poissons_ratio = 1
    block = '2'
  []
  
  [rbe_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    stress_free_temperature = 0
    thermal_expansion_coeff = 0
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = 2
  []

  [stress]
    type = ADComputeLinearElasticStress
  []
[]

[BCs]
  [heat_flux]
    type = ADNeumannBC
    variable = temperature
    boundary = 'SS.BEAM_RECEIPT_FACE'
    value = 2000000
  []
 
  [heat_removal_backplate]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = 'SS.BASE_WETTED'
    heat_transfer_coefficient = 10000
    T_infinity = 295.15
  [../]
[]

[Constraints]
    [rbe3_x_hole]
        type = RBEConstraint
        primary_node_set_id = 4
        secondary_node_set_id = 6
        variable = disp_x
        primary_size = ${pih_size}
        penalty = ${penalty}
    []

    [rbe3_y_hole]
        type = RBEConstraint
        primary_node_set_id = 4
        secondary_node_set_id = 6
        variable = disp_y
        primary_size = ${pih_size}
        penalty = ${penalty}
    []

    [rbe3_z_hole]
        type = RBEConstraint
        primary_node_set_id = 4
        secondary_node_set_id = 6
        variable = disp_z
        primary_size = ${pih_size}
        penalty = ${penalty}
    []

    [rbe3_x_slot]
        type = RBEConstraint
        primary_node_set_id = 3
        secondary_node_set_id = 5
        variable = disp_x
        primary_size = ${pis_size}
        penalty = ${penalty}
    []

    [rbe3_y_slot]
        type = RBEConstraint
        primary_node_set_id = 3
        secondary_node_set_id = 5
        variable = disp_y
        primary_size = ${pis_size}
        penalty = ${penalty}
    []
[]

    
[Executioner]
  type = Steady
  #start_time = 0
  #end_time = 1.5
  #dt = 0.1
  #steady_state_tolerance = 1e-6
  #steady_state_detection = true
  automatic_scaling = true
  compute_scaling_once = false
  solve_type = NEWTON

  petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_max_levels -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_interp_type'
  petsc_options_value = 'hypre boomeramg 0.7 4 5 25 HMIS ext+i'

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-8
  l_tol = 1e-80
  l_abs_tol = 1e-10
  l_max_its = 100
  line_search = none
[]

[Outputs]
  exodus = true
#  nemesis = true
  perf_graph = true
[]

[Debug]
  show_var_residual_norms = true
[]
