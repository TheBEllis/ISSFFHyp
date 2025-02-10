#include "is_hypreApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
is_hypreApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

is_hypreApp::is_hypreApp(InputParameters parameters) : MooseApp(parameters)
{
  is_hypreApp::registerAll(_factory, _action_factory, _syntax);
}

is_hypreApp::~is_hypreApp() {}

void
is_hypreApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<is_hypreApp>(f, af, s);
  Registry::registerObjectsTo(f, {"is_hypreApp"});
  Registry::registerActionsTo(af, {"is_hypreApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
is_hypreApp::registerApps()
{
  registerApp(is_hypreApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
is_hypreApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  is_hypreApp::registerAll(f, af, s);
}
extern "C" void
is_hypreApp__registerApps()
{
  is_hypreApp::registerApps();
}
