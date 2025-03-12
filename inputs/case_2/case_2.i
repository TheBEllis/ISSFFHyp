penalty = 1e6
pih_size = 1079901
pis_size = 1323015

ccz_blocks = "7 8 9 10 11 12 13 14"
nickel_blocks = "3 4 5 6"
steel_blocks = "1 2"

  
[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  thermal_expansion_function_reference_temperature = 293.15
  stress_free_temperature = 293.15
[]
[Mesh]
  [meshy]
    type = FileMeshGenerator
    file = '../../mesh/case_2/case_2.cpa.gz'
    skip_partitioning = True
  []
 # [fo]
 #   type = ElementOrderConversionGenerator
 #   input = meshy
 #   conversion_type = FIRST_ORDER
 # []
  allow_renumbering = false
  construct_side_list_from_node_list=true
[] 
  
[Variables]
  [temperature]
    family = LAGRANGE
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
  []
[]

[AuxVariables]
  [principal_nodal]
    order = SECOND
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [principal_nodal]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = principal_nodal
    scalar_type = MaxPrincipal
  [../]
[]

[ICs]
  [disp_x]
    type = ConstantIC
    variable = disp_x
    value = 0.0000 # m
  []
  [disp_y]
    type = ConstantIC
    variable = disp_y
    value = 0.0000  # m
  []
  [disp_z]
    type = ConstantIC
    variable = disp_z
    value = 0.0000  # m
  []
[]

[Problem]
  error_on_jacobian_nonzero_reallocation = false
  
  prefer_hash_table_matrix_assembly = true
[]  
  
[Kernels]
  # Heat conduction kernels
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
    use_displaced_mesh = False
  []
[]

[Modules/TensorMechanics/Master]
  [copper_and_nickel]
    use_automatic_differentiation = true
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    eigenstrain_names = 'eigenstrain'
    #incremental = false
    generate_output = 'max_principal_stress'
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
  []
  [steel_and_rbe]
    use_automatic_differentiation = true
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    #incremental = false
    generate_output = 'max_principal_stress'
    block = '1 2 15'
  []
[]
  
[UserObjects]
  [heat_flux_csv]
     type = PropertyReadFile
     prop_file_name = ../../HeatFlux/RotatedHeatFlux.csv
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
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus= 'ccz_ym'
    poissons_ratio = 0.33
    block = ${ccz_blocks}
  []

  [CCZ_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat_temperature_function = cucrzr_sh_fn
    thermal_conductivity_temperature_function = cucrzr_tc_fn
    block = ${ccz_blocks}
  []

  [CCZ_ym]
    type = ADPiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'ccz_ym'
    x = '2.000E+01 1.000E+02 1.500E+02 2.000E+02 2.500E+02 3.000E+02 3.500E+02 4.000E+02 4.500E+02 5.000E+02 6.000E+02 7.000E+02'
    y = '1.275E+11 1.270E+11 1.250E+11 1.230E+11 1.210E+11 1.180E+11 1.160E+11 1.130E+11 1.100E+11 1.060E+11 9.500E+10 8.600E+10'
    block = ${ccz_blocks}
  []

  [CCZ_density]
    type = ADPiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'density'
    x = '0 50 100 150 200 250 300 350 400 450 500'
    y = '8900 8886 8863 8840 8816 8791 8767 8742 8716 8691 8665'
    
    block = ${ccz_blocks}
  []

  [CCZ_thermal_expansion]
    type = ADComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cucrzr_te_fn
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = ${ccz_blocks}
  []

  [nickel_elasticity]
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus = 'nickel_ym'
    poissons_ratio = 0.31
    block = ${nickel_blocks}
  []

  [nickel_ym]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'nickel_ym'
    variable = temperature
    x = '-75 25 100 150 200 300 400 500 600 700'
    y = '2.13E+11 2.07E+11 2.02E+11 1.99E+11 1.97E+11 1.91E+11 1.86E+11 1.8E+11 1.76E+11 1.64E+11'
    block = ${nickel_blocks}
  []
  
  [nickel_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat = 456
    thermal_conductivity_temperature_function = nickel_tc_fn
    block = ${nickel_blocks}
  []

  [nickel_density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8885'
    block = ${nickel_blocks}
  []

  [nickel_thermal_expansion]
    type = ADComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = nickel_te_fn
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = ${nickel_blocks}
  []

  [steel]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '7850'
    block = ${steel_blocks}
  []

  [steel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.3
    block = ${steel_blocks}
  []

  [RBE_nodes_mat]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '7850'
    block = 15
  []

  [RBE_nodes_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.3
    block = 15
  []

  [stress]
    type = ADComputeLinearElasticStress
  []
  
[]

[BCs]
  [heat_flux]
    type = ADFunctionNeumannBC
    variable = temperature
    boundary = NS.BEAM_RECEIPT_FACE
    function = heat_profile
  []
 
  [heat_removal_backplate]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = 'NS.BACKPLATE_WETTED'
    heat_transfer_coefficient = 24200
    T_infinity = 295.15
  [../]

  [heat_removal_fins]
    type = ConvectiveFluxFunction
    variable = temperature
    boundary = 'NS.BASE_WETTED'
    coefficient = htc_function
    T_infinity = 295.15
  [../]

  [Pressure]
    [bc]
      boundary = 'NS.BASE_WETTED NS.BACKPLATE_WETTED NS.PIPES_WETTED'
      function = pressure_constant
      displacements = 'disp_x disp_y disp_z'
    []
  []
[]

[Constraints]
    [rbe3_x_hole]
        type = RBEConstraint
        primary_node_set_id = 10
        secondary_node_set_id = 13
        variable = disp_x
        primary_size = ${pih_size}
        penalty = ${penalty}
    []

    [rbe3_y_hole]
        type = RBEConstraint
        primary_node_set_id = 10
        secondary_node_set_id = 13
        variable = disp_y
        primary_size = ${pih_size}
        penalty = ${penalty}
    []

    [rbe3_z_hole]
        type = RBEConstraint
        primary_node_set_id = 10
        secondary_node_set_id = 13
        variable = disp_z
        primary_size = ${pih_size}
        penalty = ${penalty}
    []

    [rbe3_x_slot]
        type = RBEConstraint
        primary_node_set_id = 11
        secondary_node_set_id = 14
        variable = disp_x
        primary_size = ${pis_size}
        penalty = ${penalty}
    []

    [rbe3_y_slot]
        type = RBEConstraint
        primary_node_set_id = 11
        secondary_node_set_id = 14
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
#  compute_scaling_once = true
  solve_type = NEWTON

  nl_rel_tol = 1e-15
  nl_abs_tol = 1e-8
  l_tol = 1e-8
  l_abs_tol = 1e-8
  l_max_its = 500
  line_search = none
[]

[Outputs]
#  exodus = true
  nemesis = true
  perf_graph = true
  [pgraph]
    type = PerfGraphOutput
    execute_on = 'initial final'  # Default is "final"
    level = 2                     # Default is 1
    #heaviest_branch = true        # Default is false
    #heaviest_sections = 7         # Default is 0
  []  
[]

[Preconditioning]
  [FSP]
    type = FSP
    topsplit = split
  [split]
    splitting = 'sides nosides'
    splitting_type = additive
    petsc_options_iname = '-ksp_gmres_restart'
    petsc_options_value = '500'
  []
  [./nosides]
    vars = 'disp_x disp_y disp_z temperature'
    petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
    petsc_options_value = 'preonly hypre boomeramg 0.7 ext+i HMIS 10 5 0.3'
    unside_by_var_var_name = 'disp_x disp_x disp_x disp_x disp_y disp_y disp_y disp_y disp_z disp_z disp_z disp_z'
    unside_by_var_boundary_name = 'NS.PIN_HOLE_CONTACT NS.PIN_SLOT_CONTACT NS.PIN_HOLE_SUPPORT NS.PIN_SLOT_SUPPORT NS.PIN_HOLE_CONTACT NS.PIN_SLOT_CONTACT NS.PIN_HOLE_SUPPORT NS.PIN_SLOT_SUPPORT NS.PIN_HOLE_CONTACT NS.PIN_SLOT_CONTACT NS.PIN_HOLE_SUPPORT NS.PIN_SLOT_SUPPORT'
  [../]
  [./sides]
    vars = 'disp_x disp_y disp_z'
    petsc_options_iname = '-ksp_type -pc_type'
    petsc_options_value = 'gmres   jacobi'
    sides = 'NS.PIN_HOLE_CONTACT NS.PIN_SLOT_CONTACT NS.PIN_HOLE_SUPPORT NS.PIN_SLOT_SUPPORT'
  [../]
  []
[]

  
[Debug]
  show_var_residual_norms = true
[]

[Postprocessors]
  [max_temp]
    type = NodalExtremeValue
    variable = temperature
    block = '3 4 5 6 7 8 9 10 11 12 13 14'
  []
  
  [peak_nodal_average_inner_fillet]
    type = SideExtremeValue
    boundary = NS.MOUNT_INNER_FILLETS
    variable = max_principal_stress
  []
  [peak_nodal_average_outer_fillet]
    type = SideExtremeValue
    boundary = NS.MOUNT_OUTER_FILLETS
    variable = max_principal_stress
  []
  [peak_nodal_average_backplate_interface]
    type = SideExtremeValue
    boundary = NS.MOUNT_BACKPLATE_INTERFACE
    variable = max_principal_stress
  []
  [peak_nodal_average_backplate_fillet]
    type = SideExtremeValue
    boundary = NS.BACKPLATE_STEP_FILLET
    variable = max_principal_stress
  []

  [peak_nodal_average_base_end_fillet]
    type = SideExtremeValue
    boundary = NS.BASE_END_FILLET
    variable = max_principal_stress
  []
  
  [nodal_average_inner_fillet]
    type = SideAverageValue
    boundary = NS.MOUNT_INNER_FILLETS
    variable = max_principal_stress
  []
  [nodal_average_outer_fillet]
    type = SideAverageValue
    boundary = NS.MOUNT_OUTER_FILLETS
    variable = max_principal_stress
  []
  [nodal_average_backplate_interface]
    type = SideAverageValue
    boundary = NS.MOUNT_BACKPLATE_INTERFACE
    variable = max_principal_stress
  []
  [nodal_average_backplate_fillet]
    type = SideAverageValue
    boundary = NS.BACKPLATE_STEP_FILLET
    variable = max_principal_stress
  []

  [nodal_average_base_end_fillet]
    type = SideAverageValue
    boundary = NS.BASE_END_FILLET
    variable = max_principal_stress
  []
  [memory_usage]
    type = MemoryUsage
    value_type = "total"
    mem_units = 'mebibytes'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
