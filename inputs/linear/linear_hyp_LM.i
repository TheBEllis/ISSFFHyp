[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [hyp]
    type = FileMeshGenerator
    file = '../../mesh/IS_hyp.e'
  []
[] 
  
[Variables]
  [temperature]
    initial_condition = 293.15 # Start at room temperature
  []
  [lambda_x_hole]
    family = SCALAR
    order = FIRST
  []
  [lambda_y_hole]
    family = SCALAR
    order = FIRST
  []
  [lambda_z_hole]
    family = SCALAR
    order = FIRST
  []

  [lambda_x_slot]
    family = SCALAR
    order = FIRST
  []
  [lambda_y_slot]
    family = SCALAR
    order = FIRST
  []
  [lambda_z_slot]
    family = SCALAR
    order = FIRST
  []
[]
  
[Kernels]
  # Heat conduction kernels
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
    block = '1 2'
  []

  # LM kernels for average displacement constraint
  [x_lm_hole]
    type = ScalarLagrangeMultiplier
    variable = disp_x
    lambda = lambda_x_hole
  []  
  [y_lm_hole]
    type = ScalarLagrangeMultiplier
    variable = disp_y
    lambda = lambda_y_hole
  []  
  [z_lm_hole]
    type = ScalarLagrangeMultiplier
    variable = disp_z
    lambda = lambda_z_hole
  []  

  [x_lm_slot]
    type = ScalarLagrangeMultiplier
    variable = disp_x
    lambda = lambda_x_slot
  []  
  [y_lm_slot]
    type = ScalarLagrangeMultiplier
    variable = disp_y
    lambda = lambda_y_slot
  []  
  [z_lm_slot]
    type = ScalarLagrangeMultiplier
    variable = disp_z
    lambda = lambda_z_slot
  []  
[]

[ScalarKernels]
  [constraint_x_hole]
    type = AverageValueConstraint
    variable = lambda_x_hole
    pp_name = average_x_hole
    value = 0
  []
  [constraint_y_hole]
    type = AverageValueConstraint
    variable = lambda_y_hole
    pp_name = average_y_hole
    value = 0
  []
  [constraint_z_hole]
    type = AverageValueConstraint
    variable = lambda_z_hole
    pp_name = average_z_hole
    value = 0
  []

  [constraint_x_slot]
    type = AverageValueConstraint
    variable = lambda_x_slot
    pp_name = average_x_slot
    value = 0
  []
  [constraint_y_slot]
    type = AverageValueConstraint
    variable = lambda_y_slot
    pp_name = average_y_slot
    value = 0
  []
  [constraint_z_slot]
    type = AverageValueConstraint
    variable = lambda_z_slot
    pp_name = average_z_slot
    value = 0
  []
[]

[Postprocessors]
  [average_x_hole]
    type = AverageNodalVariableValue
    variable = disp_x
    boundary = 'pin_in_hole'
  []
  [average_y_hole]
    type = AverageNodalVariableValue
    variable = disp_y
    boundary = 'pin_in_hole'
  []
  [average_z_hole]
    type = AverageNodalVariableValue
    variable = disp_z
    boundary = 'pin_in_hole'
  []

  [average_x_slot]
    type = AverageNodalVariableValue
    variable = disp_x
    boundary = 'pin_in_slot'
  []
  [average_y_slot]
    type = AverageNodalVariableValue
    variable = disp_y
    boundary = 'pin_in_slot'
  []
  [average_z_slot]
    type = AverageNodalVariableValue
    variable = disp_z
    boundary = 'pin_in_slot'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    use_automatic_differentiation = true
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    #incremental = false
    #generate_output = 'strain_xx strain_yy strain_zz vonmises_stress'
  []
[]
  
[UserObjects]
  [heat_flux_csv]
     type = PropertyReadFile
     prop_file_name = ../../HeatFlux/HeatFlux.csv
     read_type = 'voronoi'
     nprop = 4
     nvoronoi = 5682
  []
[]

# Functions to control variable material parameters
[Functions]
  [htc_function]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../../HeatFlux/HTC.csv
    format = columns
  []  
  
  #Gaussian Heat profile
  [heat_profile]
    type = PiecewiseConstantFromCSV
    read_type = voronoi
    read_prop_user_object = heat_flux_csv
    column_number = 3
  []

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
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.2e11
    poissons_ratio = 0.33
    block = 1
  []

  [CCZ_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat = 400
    thermal_conductivity = 340
    block = 1
  []

  [CCZ_density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8900'
    block = 1
  []

  [CCZ_thermal_expansion]
    type = ComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 1.670e-05
    stress_free_temperature = 0.0
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = 1
  []

  [nickel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.8e11
    poissons_ratio = 0.31
    block = 2
  []
  
  [nickel_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat = 456
    thermal_conductivity = 60
    block = 2
  []

  [nickel_density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8885'
    block = 2
  []

  [nickel_thermal_expansion]
    type = ComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 1.2e-05
    stress_free_temperature = 0.0
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = 2
  []

  [steel]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '7850'
    block = 3
  []

  [steel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.3
    block = 3
  []

  [stress]
    type = ADComputeLinearElasticStress
  []
[]

[BCs]
  [heat_flux]
    type = ADFunctionNeumannBC
    variable = temperature
    boundary = 'heat_source'
    function = heat_profile
  []

  [heat_removal_backplate]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = 'heat_flux_backplate'
    heat_transfer_coefficient = 24200
    T_infinity = 295.15
  [../]

  [heat_removal_fins]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = 'heat_flux_fins'
    heat_transfer_coefficient = 48491
    T_infinity = 295.15
  [../]
  
  [Pressure]
    [bc]
      boundary = 'pressure'
      function = pressure_constant
      displacements = 'disp_x disp_y disp_z'
    []
  []
[]
  
[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  automatic_scaling = true
  compute_scaling_once = false
  solve_type = NEWTON
  #petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type'
  #petsc_options_value = '300                 asm      cholesky'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-8
  l_abs_tol = 1e-10
  line_search = none
[]

[Outputs]
  #print_linear_residuals = false
  exodus = true
  perf_graph = true
[]

