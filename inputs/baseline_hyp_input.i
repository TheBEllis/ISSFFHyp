[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = true
[]

[Mesh]
  [cmg]
    type = FileMeshGenerator
    file = '../mesh/IS_hyp.e'
    boundary_id = '1 2 3 4 5 6'
    boundary_name = 'heat_source, heat_flux_backplate, heat_flux_fins, pressure, pin_in_hole, pin_in_slot'
  []
[] 
  
[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [lambda_x]
    family = SCALAR
    order = FIRST
  []
  [lambda_y]
    family = SCALAR
    order = FIRST
  []
  [lambda_z]
    family = SCALAR
    order = FIRST
  []
  [temperature]
    initial_condition = 293.15 # Start at room temperature
  []
[]

[BCs]
  [bc]
    type = ADDirichletBC
    variable = disp_x
    boundary = 'pin_in_hole'
    value = 0
  []
[]
  
[Kernels]

  # Heat conduction kernels
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
  []
  [heat_conduction_time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = temperature
  []

  # LM kernels for average displacement constraint
  [x_lm]
    type = ScalarLagrangeMultiplier
    variable = disp_x
    lambda = lambda_x
  []  
  [y_lm]
    type = ScalarLagrangeMultiplier
    variable = disp_y
    lambda = lambda_y
  []  
  [z_lm]
    type = ScalarLagrangeMultiplier
    variable = disp_z
    lambda = lambda_z
  []  
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    use_automatic_differentiation = true
    strain = SMALL
    add_variables = true
    incremental = false
    generate_output = 'strain_xx strain_yy strain_zz vonmises_stress'
  []
[]
  
[ScalarKernels]
  [constraint_x]
    type = AverageValueConstraint
    variable = lambda_x
    pp_name = average_x
    value = 0
  []
  [constraint_y]
    type = AverageValueConstraint
    variable = lambda_y
    pp_name = average_y
    value = 0
  []
  [constraint_z]
    type = AverageValueConstraint
    variable = lambda_z
    pp_name = average_z
    value = 0
  []
[]

[UserObjects]
  [heat_flux_csv]
     type = PropertyReadFile
     prop_file_name = SimData/HeatFlux/HeatFlux.csv
     read_type = 'voronoi'
     nprop = 4
     nvoronoi = 3
  []
[]

# Functions to control variable material parameters
[Functions]
  # Gaussian Heat profile
  [./heat_profile]
    type = PiecewiseConstantFromCSV
    read_type = voronoi
    read_prop_user_object = heat_flux_csv
    column_number = 3
  [../]

  [./pressure_constant]
    type = ConstantFunction
    value = 0.7e6 # 0.7 MPa
  [../]
  
  [./cucrzr_rho_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../MaterialData/Copper/density.csv
  [../]

  # Copper Youngs modulus
  [./cucrzr_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../MaterialData/Copper/youngs_modulus.csv
  [../]
  
  #Copper Thermal conductivity
  [./cucrzr_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../MaterialData/Copper/thermal_conductivity.csv
  [../]

  #Copper Thermal expansion
  [./cucrzr_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../MaterialData/Copper/thermal_expansion.csv
  [../]

  #Nickel youngs modulus
  [./nickel_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../MaterialData/Nickel/youngs_modulus.csv
  [../]
  
  #Nickel thermal conductivity
  [./nickel_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0youngs_modulus = '110e9'
    poissons_ratio = 0.33
    data_file = ../MaterialData/Nickel/thermal_conductivity.csv
  [../]

  #Nickel thermal expansion
  [./nickel_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../MaterialData/Nickel/thermal_expansion.csv
  [../]
[]

  
[Materials]
  [CCZ_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ccz_ym
    poissons_ratio = 0.33
    block = 1
  []

  [CCZ_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat_temperature_function = cucrzr_sh
    thermal_conductivity_temperature_function = cucrzr_tc
    block = 1
  []

  [CCZ_ym]
    type = ADCoupledValueFunctionMaterial
    function = cucrzr_ym_fn
    prop_name = 'ccz_ym'
    v = temperature
    block = 1
  []

  [CCZ_density]
    type = ADCoupledValueFunctionMaterial
    function = cucrzr_rho_fn
    prop_name = 'ccz_rho'
    v = temperature
    block = 1
  []

  [CCZ_stress]
    type = ADComputeLinearElasticStress
    block = 2
  []

  [nickel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = '110e9'
    poissons_ratio = 0.33
    block = 2
  []
  [nickel_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat_temperature_function = nickel_sh
    thermal_conductivity_temperature_function = nickel_tc
    block = 2
  []
  [nickel_stress]
    type = ADComputeLinearElasticStress
    block = 2
  []
[]


[BCs]
  [inlet_temperature]
    type = DirichletBC
    variable = temperature
    boundary = 'all_sides'
    value = 293.15
  []
  [heat_flux]
    type = ADFunctionNeumannBC
    variable = temperature
    boundary = 'heat_source'
    function = heat_profile
  []
  [heat_removal]
    type = ADConvectiveFluxFunction
    variable = temperature
    boundary = 'htc'
    coefficient = htc_function
    T_infinity = 293.15
  [../]
  # the following bcs should be rbe3?
  [hold_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'fixed'
    value = 0
  []
  [hold_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'fixed'
    value = 0
  []
  [hold_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'fixed'
    value = 0
  []
  [./Pressure]
    [./bc]
      boundary = 'pressure'
      function = pressure_constant
      displacements = 'disp_x disp_y disp_z'
    [../]
  []
[]
  
[Postprocessors]
  [average_x]
    type = AverageNodalVariableValue
    variable = disp_x
    boundary = 'bolt'
  []
  [average_y]
    type = AverageNodalVariableValue
    variable = disp_y
    boundary = 'bolt'
  []
  [average_z]
    type = AverageNodalVariableValue
    variable = disp_z
    boundary = 'bolt'
  []
[]

[Preconditioning]
  [./SMP]
    #Creates the entire Jacobian, for the Newton solve
    type = SMP
    full = true
  [../]
[]
  
[Executioner]
  automatic_scaling = true
  solve_type = 'NEWTON'
  type = Steady
  line_search = none
  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-8
  l_tol = 1e-6

  l_max_its = 100
  nl_max_its = 10
  
  petsc_options_iname = '-mat_view'
  petsc_options_value = ' :filename'
  #petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  #petsc_options_value = 'hypre boomeramg 31'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
  perf_graph = true
[]

