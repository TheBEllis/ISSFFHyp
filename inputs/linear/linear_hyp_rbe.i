[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [hyp]
    type = FileMeshGenerator
    file = '../mesh/IS_hyp.e'
  []
[] 
  
[Variables]
  [temperature]
    initial_condition = 293.15 # Start at room temperature
  []
[]
  
[Kernels]
  # Heat conduction kernels
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
    block = '1 2'

  []
  [heat_conduction_time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    block = '1 2'
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
     prop_file_name = ../HeatFlux/HeatFlux.csv
     read_type = 'voronoi'
     nprop = 4
     nvoronoi = 5682
  []
[]

# Functions to control variable material parameters
[Functions]
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
    data_file = '../MaterialData/Copper/density.csv'
    format = columns
  [../]

  # Copper Youngs modulus
  [./cucrzr_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Copper/youngs_modulus.csv'
    format = columns
  [../]
  
  #Copper Thermal conductivity
  [./cucrzr_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Copper/thermal_conductivity.csv'
    format = columns
  [../]

  #Copper Thermal expansion
  [./cucrzr_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Copper/thermal_expansion.csv'
    format = columns
  [../]

  # Copper specific heat
  [./cucrzr_sh_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Copper/specific_heat.csv'
    format = columns
  [../]

  #Nickel youngs modulus
  [./nickel_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Nickel/youngs_modulus.csv'
    format = columns
  [../]
  
  #Nickel thermal conductivity
  [./nickel_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Nickel/thermal_conductivity.csv'
    format = columns
  [../]

  #Nickel thermal expansion
  [nickel_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../MaterialData/Nickel/thermal_expansion.csv'
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
 
  [Pressure]
    [bc]
      boundary = 'pressure'
      function = pressure_constant
      displacements = 'disp_x disp_y disp_z'
    []
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
  type = Transient
  start_time = 0
  end_time = 1.5
  dt = 0.1
  steady_state_tolerance = 1e-6
  steady_state_detection = true
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
  print_linear_residuals = false
  exodus = true
  perf_graph = true
[]
